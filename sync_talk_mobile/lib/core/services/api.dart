import 'package:dio/dio.dart';

import 'session.dart';
import '../config/app_env.dart';
import 'dart:async';
import 'dart:convert';
import '../../main.dart';

class ApiClient {
  static final String baseUrl = AppEnv.baseUrl;
  static bool _isRefreshing = false;
  static final List<Completer<String?>> _refreshCompleters = [];

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static void initialize() {
    // Request Interceptor - Add JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Normalize path: Ensure all local request paths are prefixed with /api
          String path = options.path;
          if (!path.startsWith('http://') &&
              !path.startsWith('https://') &&
              !path.startsWith('/api/') &&
              !path.startsWith('api/') &&
              path != '/api' &&
              path != 'api') {
            if (path.startsWith('/')) {
              options.path = '/api$path';
            } else {
              options.path = '/api/$path';
            }
          } else if (path.startsWith('api/')) {
            options.path = '/$path'; // Adds leading slash if missing
          }

          print('✈️ [API REQUEST] ${options.method} ${options.baseUrl}${options.path}');
          if (options.data != null) {
            print('Request Body: ${options.data}');
          }

          // Skip token for auth endpoints
          if (options.path.contains('/auth/login') ||
              options.path.contains('/auth/register') ||
              options.path.contains('/auth/google') ||
              options.path.contains('/auth/refresh')) {
            return handler.next(options);
          }

          // Add access token to headers
          final token = await session.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token'; // Backend auth middleware expects Bearer token
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          print('❌ [API ERROR] ${error.response?.statusCode} ${error.requestOptions.path}');
          print('Error Body: ${error.response?.data}');
          print('Exception: $error');

          if (error.response?.statusCode == 401) {
            // Skip refresh for auth endpoints themselves
            final path = error.requestOptions.path;
            if (path.contains('/auth/login') ||
                path.contains('/auth/register') ||
                path.contains('/auth/google') ||
                path.contains('/auth/refresh')) {
              return handler.next(error);
            }

            // Check if this request has already been retried
            if (error.requestOptions.extra['retried'] == true) {
              return handler.next(error);
            }

            final refreshToken = await session.getRefreshToken();
            if (refreshToken == null) {
              await session.clear();
              appRouter.go('/login');
              return handler.next(error);
            }

            if (_isRefreshing) {
              final completer = Completer<String?>();
              _refreshCompleters.add(completer);
              final token = await completer.future;
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                error.requestOptions.extra['retried'] = true;
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  return handler.resolve(response);
                } on DioException catch (e) {
                  return handler.next(e);
                }
              }
              return handler.next(error);
            }

            _isRefreshing = true;
            try {
              // Create a temporary Dio client for the refresh request to avoid interceptor loops
              final refreshDio = Dio();
              final response = await refreshDio.post(
                '${AppEnv.baseUrl}/api/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              var responseData = response.data;
              if (responseData is String) {
                responseData = jsonDecode(responseData);
              }
              final newAccessToken = responseData['accessToken'] as String;
              final newRefreshToken = responseData['refreshToken'] as String;

              await session.setTokens(newAccessToken, newRefreshToken);

              // Complete all pending requests in queue
              for (var c in _refreshCompleters) {
                c.complete(newAccessToken);
              }
              _refreshCompleters.clear();
              _isRefreshing = false;

              // Retry the original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              error.requestOptions.extra['retried'] = true;
              final retryResponse = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              _isRefreshing = false;
              for (var c in _refreshCompleters) {
                c.complete(null);
              }
              _refreshCompleters.clear();

              // Refresh failed - logout and redirect to login screen
              await session.clear();
              appRouter.go('/login');
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('✅ [API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          print('Response Body: ${response.data}');
          return handler.next(response);
        }
      ),
    );
  }

  static Dio get instance => _dio;
  static Dio get dio => _dio;
}

// Global dio instance
final dio = ApiClient.instance;

// Initialize API client (call in main.dart)
void initApi() {
  ApiClient.initialize();
}
