// import 'package:dio/dio.dart';
// import 'session.dart';

// final dio =
//     Dio(
//         BaseOptions(
//           baseUrl: const String.fromEnvironment(
//             'API_BASE',
//             defaultValue: 'http://192.168.1.8:4000',
//           ),
//         ),
//       )
//       ..interceptors.add(
//         InterceptorsWrapper(
//           onRequest: (options, handler) {
//             final token = session.accessToken;
//             if (token != null)
//               options.headers['Authorization'] = 'Bearer $token';
//             handler.next(options);
//           },
//         ),
//       );

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// Use your laptop LAN IP (same Wi-Fi as phone).
// /// Example: http://192.168.1.8:4000
// const String apiBase = String.fromEnvironment(
//   'API_BASE_URL',
//   defaultValue: 'http://192.168.1.8:4000',
// );

// class Api {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: apiBase,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 20),
//     ),
//   );

//   String _friendlyError(Object err) {
//     if (err is DioException) {
//       final data = err.response?.data;
//       if (data is Map && data['message'] is String) return data['message'] as String;
//       if (err.type == DioExceptionType.connectionTimeout ||
//           err.type == DioExceptionType.sendTimeout ||
//           err.type == DioExceptionType.receiveTimeout) {
//         return 'Server timeout. Check Wi-Fi and API base URL.';
//       }
//       if (err.type == DioExceptionType.connectionError) return 'Cannot reach server at $apiBase';
//       return 'Request failed';
//     }
//     return 'Unexpected error';
//   }

//   Future<Dio> _authed() async {
//     final prefs = await SharedPreferences.getInstance();
//     final t = prefs.getString('token');
//     final d = _dio;
//     if (t != null) d.options.headers['Authorization'] = 'Bearer $t';
//     return d;
//   }

//   Future<Map<String, dynamic>> register(String email, String password) async {
//     try {
//       final res = await _dio.post('/auth/register', data: {'email': email, 'password': password});
//       return Map<String, dynamic>.from(res.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final r = await _dio.post('/auth/login', data: {'email': email, 'password': password});
//       final token = r.data['accessToken'] as String?;
//       if (token != null) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', token);
//       }
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> me() async {
//     try {
//       final d = await _authed();
//       final r = await d.get('/users/me');
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<List<dynamic>> listConversations({int page = 1, int limit = 20}) async {
//     try {
//       final d = await _authed();
//       final r = await d.get('/conversations', queryParameters: {'page': page, 'limit': limit});
//       return r.data as List<dynamic>;
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> createConversation({String? name, List<String>? participants}) async {
//     try {
//       final d = await _authed();
//       final r = await d.post('/conversations', data: {
//         'name': name,
//         'participants': participants ?? <String>[],
//       });
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> sendMessage(String conversationId, String text) async {
//     try {
//       final d = await _authed();
//       final r = await d.post('/messages', data: {'conversationId': conversationId, 'text': text});
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// const String apiBase = String.fromEnvironment(
//   'API_BASE_URL',
//   // If you're running backend on your laptop & device is Android emulator, use 10.0.2.2
//   // For physical device on same Wi-Fi, use your laptop’s LAN IP like http://192.168.1.8:4000
//   defaultValue: 'http://192.168.1.8:4000',
// );

// class Api {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: apiBase,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 20),
//     ),
//   );

//   String _friendlyError(Object err) {
//     if (err is DioException) {
//       final data = err.response?.data;
//       if (data is Map && data['message'] is String)
//         return data['message'] as String;
//       if (err.type == DioExceptionType.connectionTimeout ||
//           err.type == DioExceptionType.sendTimeout ||
//           err.type == DioExceptionType.receiveTimeout) {
//         return 'Server timeout. Check network/API base URL.';
//       }
//       if (err.type == DioExceptionType.connectionError) {
//         return 'Cannot reach server at $apiBase';
//       }
//       return 'Request failed';
//     }
//     return 'Unexpected error';
//   }

//   Future<Dio> _authed() async {
//     final prefs = await SharedPreferences.getInstance();
//     final t = prefs.getString('token');
//     final d = _dio;
//     if (t != null) d.options.headers['Authorization'] = 'Bearer $t';
//     return d;
//   }

//   Future<Map<String, dynamic>> register(String email, String password) async {
//     try {
//       final res = await _dio.post(
//         '/auth/register',
//         data: {'email': email, 'password': password},
//       );
//       return Map<String, dynamic>.from(res.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final r = await _dio.post(
//         '/auth/login',
//         data: {'email': email, 'password': password},
//       );
//       final token = r.data['accessToken'] as String?;
//       if (token != null) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', token);
//       }
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> me() async {
//     try {
//       final d = await _authed();
//       final r = await d.get('/users/me');
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<List<dynamic>> listConversations({
//     int page = 1,
//     int limit = 20,
//   }) async {
//     try {
//       final d = await _authed();
//       final r = await d.get(
//         '/conversations',
//         queryParameters: {'page': page, 'limit': limit},
//       );
//       return r.data as List<dynamic>;
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> sendMessage(
//     String conversationId,
//     String text,
//   ) async {
//     try {
//       final d = await _authed();
//       final r = await d.post(
//         '/messages',
//         data: {'conversationId': conversationId, 'text': text},
//       );
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }

//   Future<Map<String, dynamic>> createConversation({
//     String? name,
//     List<String>? participants,
//   }) async {
//     try {
//       final d = await _authed();
//       final r = await d.post(
//         '/conversations',
//         data: {
//           'name': name,
//           // backend accepts array; empty array means only you will be a participant
//           'participants': participants ?? <String>[],
//         },
//       );
//       return Map<String, dynamic>.from(r.data);
//     } catch (e) {
//       throw Exception(_friendlyError(e));
//     }
//   }
// }

// import 'package:dio/dio.dart';
// import 'session.dart';

// class ApiClient {
//   static const String baseUrl = String.fromEnvironment(
//     'API_BASE',
//     defaultValue: 'http://10.0.2.2:4000/api', // Android emulator
//     // For iOS: 'http://localhost:4000/api'
//     // For device: 'http://YOUR_IP:4000/api'
//   );

//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     ),
//   );

//   static bool _isRefreshing = false;
//   static List<Function> _requestsQueue = [];

//   static void initialize() {
//     // Request Interceptor - Add JWT token
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           // Skip token for auth endpoints
//           if (options.path.contains('/auth/login') ||
//               options.path.contains('/auth/register') ||
//               options.path.contains('/auth/google')) {
//             return handler.next(options);
//           }

//           // Add access token to headers
//           final token = await session.getAccessToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }

//           return handler.next(options);
//         },
//         onError: (error, handler) async {
//           // Handle 401 errors (token expired)
//           if (error.response?.statusCode == 401) {
//             if (!_isRefreshing) {
//               _isRefreshing = true;

//               try {
//                 // Try to refresh token
//                 await _refreshToken();

//                 // Retry original request
//                 final opts = error.requestOptions;
//                 final token = await session.getAccessToken();
//                 opts.headers['Authorization'] = 'Bearer $token';

//                 final response = await _dio.fetch(opts);
//                 _isRefreshing = false;

//                 // Process queued requests
//                 _processQueue();

//                 return handler.resolve(response);
//               } catch (e) {
//                 _isRefreshing = false;

//                 // Clear session and force logout
//                 await session.clear();

//                 // Process queued requests with error
//                 _processQueue(error: error);

//                 return handler.reject(error);
//               }
//             } else {
//               // Queue this request while token is being refreshed
//               return _addToQueue(
//                 () => handler.resolve(error.response!),
//                 (err) => handler.reject(err),
//               );
//             }
//           }

//           return handler.next(error);
//         },
//         onResponse: (response, handler) {
//           // Log successful responses in debug mode
//           print(
//             '✅ API Response: ${response.requestOptions.path} - ${response.statusCode}',
//           );
//           return handler.next(response);
//         },
//       ),
//     );

//     // Logging Interceptor (debug mode only)
//     _dio.interceptors.add(
//       LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//         error: true,
//         logPrint: (obj) => print('🔍 API: $obj'),
//       ),
//     );
//   }

//   static Future<void> _refreshToken() async {
//     final refreshToken = await session.getRefreshToken();
//     if (refreshToken == null) {
//       throw Exception('No refresh token available');
//     }

//     final response = await _dio.post(
//       '/auth/refresh',
//       data: {'refreshToken': refreshToken},
//       options: Options(
//         headers: {}, // No auth header for refresh
//       ),
//     );

//     final data = response.data;
//     if (data['accessToken'] != null) {
//       await session.setAccessToken(data['accessToken']);
//     }
//     if (data['refreshToken'] != null) {
//       await session.setRefreshToken(data['refreshToken']);
//     }
//   }

//   static Future<void> _addToQueue(
//     Function onSuccess,
//     Function(DioException) onError,
//   ) async {
//     _requestsQueue.add(() async {
//       if (_isRefreshing) {
//         await onSuccess();
//       } else {
//         await onError(
//           DioException(
//             requestOptions: RequestOptions(path: ''),
//             error: 'Token refresh failed',
//           ),
//         );
//       }
//     });
//   }

//   static void _processQueue({DioException? error}) {
//     for (var request in _requestsQueue) {
//       request();
//     }
//     _requestsQueue.clear();
//   }

//   static Dio get instance => _dio;
// }

// // Global dio instance
// final dio = ApiClient.instance;

// // Initialize API client (call in main.dart)
// void initApi() {
//   ApiClient.initialize();
// }

// Fixed API Client with JWT Token Handling
// File: lib/src/core/services/api.dart

import 'package:dio/dio.dart';
import 'session.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:4000/api', // Android emulator
  );

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

  static bool _isRefreshing = false;
  static List<Function> _requestsQueue = [];

  static void initialize() {
    // Request Interceptor - Add JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for auth endpoints
          if (options.path.contains('/auth/login') ||
              options.path.contains('/auth/register') ||
              options.path.contains('/auth/google')) {
            return handler.next(options);
          }

          // Add access token to headers
          final token = await session.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors (token expired)
          if (error.response?.statusCode == 401) {
            if (!_isRefreshing) {
              _isRefreshing = true;

              try {
                // Try to refresh token
                await _refreshToken();

                // Retry original request
                final opts = error.requestOptions;
                final token = await session.getAccessToken();
                opts.headers['Authorization'] = 'Bearer $token';

                final response = await _dio.fetch(opts);
                _isRefreshing = false;

                // Process queued requests
                _processQueue();

                return handler.resolve(response);
              } catch (e) {
                _isRefreshing = false;

                // Clear session and force logout
                await session.clear();

                // Process queued requests with error
                _processQueue(error: error);

                return handler.reject(error);
              }
            } else {
              // Queue this request while token is being refreshed
              return _addToQueue(
                () => handler.resolve(error.response!),
                (err) => handler.reject(err),
              );
            }
          }

          return handler.next(error);
        },
        onResponse: (response, handler) {
          // Log successful responses in debug mode
          print(
            '✅ API Response: ${response.requestOptions.path} - ${response.statusCode}',
          );
          return handler.next(response);
        },
      ),
    );

    // Logging Interceptor (debug mode only)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('🔍 API: $obj'),
      ),
    );
  }

  static Future<void> _refreshToken() async {
    final refreshToken = await session.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {}, // No auth header for refresh
      ),
    );

    final data = response.data;
    if (data['accessToken'] != null) {
      await session.setAccessToken(data['accessToken']);
    }
    if (data['refreshToken'] != null) {
      await session.setRefreshToken(data['refreshToken']);
    }
  }

  static Future<void> _addToQueue(
    Function onSuccess,
    Function(DioException) onError,
  ) async {
    _requestsQueue.add(() async {
      if (_isRefreshing) {
        await onSuccess();
      } else {
        await onError(
          DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Token refresh failed',
          ),
        );
      }
    });
  }

  static void _processQueue({DioException? error}) {
    for (var request in _requestsQueue) {
      request();
    }
    _requestsQueue.clear();
  }

  static Dio get instance => _dio;
}

// Global dio instance
final dio = ApiClient.instance;

// Initialize API client (call in main.dart)
void initApi() {
  ApiClient.initialize();
}
