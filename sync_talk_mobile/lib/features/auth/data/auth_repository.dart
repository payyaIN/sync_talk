// import 'package:dio/dio.dart';
// import '../../../core/services/dio_client.dart';

// class AuthRepository {
//   final _dio = ApiClient.dio;

//   Future<Response> register(String name, String email, String password) =>
//       _dio.post(
//         '/auth/register',
//         data: {'name': name, 'email': email, 'password': password},
//       );

//   Future<Response> login(String email, String password) =>
//       _dio.post('/auth/login', data: {'email': email, 'password': password});

//   Future<Response> me() => _dio.get('/auth/me');
// }

// import 'package:dio/dio.dart';
// import '../../../core/services/dio_client.dart';

// class AuthRepository {
//   final _dio = ApiClient.dio;

//   Future<Response> register(String name, String email, String password) =>
//       _dio.post('/auth/register', data: {'name': name, 'email': email, 'password': password});

//   Future<Response> login(String email, String password) =>
//       _dio.post('/auth/login', data: {'email': email, 'password': password});

//   Future<Response> me() => _dio.get('/auth/me');
// }

// import '../../../core/utils/token_store.dart';
// import 'auth_api.dart';

// class AuthRepository {
//   final _api = AuthApi();

//   Future<Map<String, dynamic>> register(String name, String email, String password) async {
//     final data = await _api.register(name, email, password);
//     final token = data['token'] as String?;
//     if (token != null) await TokenStore.save(token);
//     return data;
//   }

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final data = await _api.login(email, password);
//     final token = data['token'] as String?;
//     if (token != null) await TokenStore.save(token);
//     return data;
//   }

//   Future<void> logout() => TokenStore.clear();

//   Future<Map<String, dynamic>?> currentUser() async {
//     final token = await TokenStore.read();
//     if (token == null) return null;
//     final data = await _api.me();
//     return data['data'] as Map<String, dynamic>?;
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';

// class AuthRepository {
//   final _auth = FirebaseAuth.instance;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   Future<UserCredential> login(String email, String password) {
//     return _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   Future<UserCredential> register(String email, String password) {
//     return _auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> logout() => _auth.signOut();
// }

// import 'package:dio/dio.dart';
// import '../../../core/services/api.dart';
// import '../../../core/services/session.dart';

// class AuthRepository {
//   final Dio _dio = dio;

//   /// Register new user with backend
//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/auth/register',
//         data: {'displayName': name, 'email': email, 'password': password},
//       );

//       return response.data;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   /// Login with email/password
//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/auth/login',
//         data: {'email': email, 'password': password},
//       );

//       final data = response.data;

//       // Store tokens
//       if (data['accessToken'] != null) {
//         await session.setAccessToken(data['accessToken']);
//       }
//       if (data['refreshToken'] != null) {
//         await session.setRefreshToken(data['refreshToken']);
//       }

//       // Store user info
//       if (data['user'] != null) {
//         await session.setUserId(data['user']['id']);
//         await session.setUser(data['user']);
//       }

//       return data;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   /// Login with Google OAuth
//   Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
//     try {
//       final response = await _dio.post(
//         '/auth/google',
//         data: {'idToken': idToken},
//       );

//       final data = response.data;

//       // Store tokens
//       if (data['accessToken'] != null) {
//         await session.setAccessToken(data['accessToken']);
//       }
//       if (data['refreshToken'] != null) {
//         await session.setRefreshToken(data['refreshToken']);
//       }

//       // Store user info
//       if (data['user'] != null) {
//         await session.setUserId(data['user']['id']);
//         await session.setUser(data['user']);
//       }

//       return data;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   /// Refresh access token
//   Future<void> refreshAccessToken() async {
//     try {
//       final refreshToken = await session.getRefreshToken();
//       if (refreshToken == null) {
//         throw Exception('No refresh token available');
//       }

//       final response = await _dio.post(
//         '/auth/refresh',
//         data: {'refreshToken': refreshToken},
//       );

//       final data = response.data;

//       if (data['accessToken'] != null) {
//         await session.setAccessToken(data['accessToken']);
//       }
//       if (data['refreshToken'] != null) {
//         await session.setRefreshToken(data['refreshToken']);
//       }
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   /// Get current user info
//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       final response = await _dio.get('/users/me');
//       final user = response.data;

//       if (user != null) {
//         await session.setUser(user);
//       }

//       return user;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   /// Logout
//   Future<void> logout() async {
//     await session.clear();
//   }

//   /// Check if user is logged in
//   Future<bool> isLoggedIn() async {
//     final token = await session.getAccessToken();
//     return token != null && token.isNotEmpty;
//   }

//   String _handleError(DioException e) {
//     if (e.response != null) {
//       final message =
//           e.response?.data['error'] ??
//           e.response?.data['message'] ??
//           'An error occurred';
//       return message;
//     } else if (e.type == DioExceptionType.connectionTimeout) {
//       return 'Connection timeout. Please check your internet connection.';
//     } else if (e.type == DioExceptionType.connectionError) {
//       return 'Cannot connect to server. Please try again later.';
//     } else {
//       return 'An unexpected error occurred';
//     }
//   }
// }

// Fixed Authentication Repository - Backend JWT Implementation
// File: lib/src/features/auth/data/auth_repository.dart

// class AuthRepository {
//   final Dio _dio = dio;

//   /// Register new user with backend
//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/auth/register',
//         data: {'displayName': name, 'email': email, 'password': password},
//       );

//       return response.data;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

/// Login with email/password
// Future<Map<String, dynamic>> login({
//   required String email,
//   required String password,
// }) async {
//   try {
//     final response = await _dio.post(
//       '/auth/login',
//       data: {'email': email, 'password': password},
//     );

//     final data = response.data;

//     // Store tokens
//     if (data['accessToken'] != null) {
//       await session.setAccessToken(data['accessToken']);
//     }
//     if (data['refreshToken'] != null) {
//       await session.setRefreshToken(data['refreshToken']);
//     }

//     // Store user info
//     if (data['user'] != null) {
//       await session.setUserId(data['user']['id']);
//       await session.setUser(data['user']);
//     }

//     return data;
//   } on DioException catch (e) {
//     throw _handleError(e);
//   }
// }
// File: lib/features/auth/data/auth_repository.dart
// Complete AuthRepository with all required methods

import 'package:dio/dio.dart';
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

      final data = resp.data;

      // Store tokens
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        await session.setAccessToken(data['accessToken']);
        await session.setRefreshToken(data['refreshToken']);
      }

      // Store user info
      if (data['user'] != null) {
        await session.setUserId(data['user']['id']);
        await session.setUser(data['user']);
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

      final data = resp.data;

      // Store tokens
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        await session.setAccessToken(data['accessToken']);
        await session.setRefreshToken(data['refreshToken']);
      }

      // Store user info
      if (data['user'] != null) {
        await session.setUserId(data['user']['id']);
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

      final data = response.data;

      // Store tokens
      if (data['accessToken'] != null) {
        await session.setAccessToken(data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await session.setRefreshToken(data['refreshToken']);
      }

      // Store user info
      if (data['user'] != null) {
        await session.setUserId(data['user']['id']);
        await session.setUser(data['user']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await session.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;

      if (data['accessToken'] != null) {
        await session.setAccessToken(data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await session.setRefreshToken(data['refreshToken']);
      }
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

      final resp = await _dio.get('/users/me');
      final user = resp.data;

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
    try {
      final refreshToken = await session.getRefreshToken();
      if (refreshToken != null) {
        // Optionally call backend logout endpoint
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      // Always clear session
      await session.clear();
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await session.isLoggedIn();
  }

  /// Handle Dio errors
  String _handleError(DioException e) {
    if (e.response != null) {
      final message =
          e.response?.data['error'] ??
          e.response?.data['message'] ??
          'An error occurred';
      return message;
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please try again later.';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
