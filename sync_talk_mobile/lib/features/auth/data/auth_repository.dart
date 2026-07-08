import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/services/api.dart';
import '../../../core/services/session.dart';

class AuthRepository {
  final Dio _dio = dio; // Use the global dio instance

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post(
        '/auth/register',
        data: {'displayName': name, 'email': email, 'password': password}, 
      );

      var data = resp.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data['success'] == true && data['user'] != null) {
          // It seems the backend returns { success: true, message: ..., user: ... } but no token on register?
          // Let's check auth.controller.ts. 
          // Register returns { success: true, message: ..., user: ... }. NO TOKEN.
          // Login returns { success: true, message: ..., token: ..., user: ... }.
          // So after register, we might need to login or just return success.
          return data;
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login existing user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      var data = resp.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      // Store tokens
      final token = data['token'] ?? data['accessToken'];
      final refreshToken = data['refreshToken'];
      if (token != null && refreshToken != null) {
        await session.setTokens(token, refreshToken);
      } else if (token != null) {
        await session.setAccessToken(token);
      }

      // Store user info
      if (data['user'] != null) {
        final userId = data['user']['_id'] ?? data['user']['id'];
        if (userId != null) {
          await session.setUserId(userId);
        }
        await session.setUser(data['user']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with Google OAuth
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      final token = data['token'] ?? data['accessToken'];
      final refreshToken = data['refreshToken'];
      if (token != null && refreshToken != null) {
        await session.setTokens(token, refreshToken);
      } else if (token != null) {
        await session.setAccessToken(token);
      }

      if (data['user'] != null) {
        final userId = data['user']['_id'] ?? data['user']['id'];
        if (userId != null) {
          await session.setUserId(userId);
        }
        await session.setUser(data['user']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>> currentUser() async {
    try {
      if (session.accessToken == null) {
        throw Exception('Not logged in');
      }

      final resp = await _dio.get('/auth/me'); // auth.routes.ts says router.get("/me", protect, getProfile);
      var data = resp.data;
      if (data is String) {
        data = jsonDecode(data);
      }
       
      final user = data['data'];

      if (user != null) {
        await session.setUser(user);
      }

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    await session.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await session.isLoggedIn();
  }

  /// Handle Dio errors
  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        return data['error'] ?? data['message'] ?? 'An error occurred';
      } else if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map) {
            return parsed['error'] ?? parsed['message'] ?? data;
          }
        } catch (_) {}
        return data;
      }
      return 'An error occurred';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your internet connection and try again.';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
