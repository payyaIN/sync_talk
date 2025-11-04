// import 'package:hive_flutter/hive_flutter.dart';

// class Session {
//   String? accessToken;
//   String? refreshToken;
//   String? userId;
//   Future<void> load() async {
//     await Hive.initFlutter();
//     final box = await Hive.openBox('session');
//     accessToken = box.get('accessToken');
//     refreshToken = box.get('refreshToken');
//     userId = box.get('userId');
//   }
//   Future<void> save() async {
//     final box = await Hive.openBox('session');
//     await box.put('accessToken', accessToken);
//     await box.put('refreshToken', refreshToken);
//     await box.put('userId', userId);
//   }
//   void setTokens(String? access, String? refresh) {
//     accessToken = access; refreshToken = refresh; save();
//   }
// }
// final session = Session();
// Future<void> initSession() async { await session.load(); }

// Fixed Session Management with Secure Storage
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';

// class Session {
//   static const _storage = FlutterSecureStorage();

//   // Storage keys
//   static const _keyAccessToken = 'access_token';
//   static const _keyRefreshToken = 'refresh_token';
//   static const _keyUserId = 'user_id';
//   static const _keyUser = 'user_data';

//   // Access Token
//   Future<void> setAccessToken(String token) async {
//     await _storage.write(key: _keyAccessToken, value: token);
//   }

//   Future<String?> getAccessToken() async {
//     return await _storage.read(key: _keyAccessToken);
//   }

//   // Refresh Token
//   Future<void> setRefreshToken(String token) async {
//     await _storage.write(key: _keyRefreshToken, value: token);
//   }

//   Future<String?> getRefreshToken() async {
//     return await _storage.read(key: _keyRefreshToken);
//   }

//   // User ID
//   Future<void> setUserId(String userId) async {
//     await _storage.write(key: _keyUserId, value: userId);
//   }

//   Future<String?> getUserId() async {
//     return await _storage.read(key: _keyUserId);
//   }

//   // User Data
//   Future<void> setUser(Map<String, dynamic> user) async {
//     final userJson = jsonEncode(user);
//     await _storage.write(key: _keyUser, value: userJson);
//   }

//   Future<Map<String, dynamic>?> getUser() async {
//     final userJson = await _storage.read(key: _keyUser);
//     if (userJson == null) return null;
//     return jsonDecode(userJson) as Map<String, dynamic>;
//   }

//   // Check if logged in
//   Future<bool> isLoggedIn() async {
//     final token = await getAccessToken();
//     return token != null && token.isNotEmpty;
//   }

//   // Clear all session data
//   Future<void> clear() async {
//     await _storage.deleteAll();
//   }
// }

// // Global session instance
// final session = Session();

// // Initialize session (call in main.dart)
// Future<void> initSession() async {
//   // Initialization if needed
// }

//new

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const _storage = FlutterSecureStorage();
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';

  String? accessToken;
  String? refreshToken;
  String? userId;

  Future<void> load() async {
    accessToken = await _storage.read(key: _keyAccessToken);
    refreshToken = await _storage.read(key: _keyRefreshToken);
    userId = await _storage.read(key: _keyUserId);
  }

  Future<void> setTokens(String access, String refresh) async {
    accessToken = access;
    refreshToken = refresh;
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  Future<void> save() async {
    if (accessToken != null) {
      await _storage.write(key: _keyAccessToken, value: accessToken!);
    }
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken!);
    }
    if (userId != null) {
      await _storage.write(key: _keyUserId, value: userId!);
    }
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    await _storage.deleteAll();
  }

  bool get isLoggedIn => accessToken != null;
}

final session = Session();

Future<void> initSession() async {
  await session.load();
}
