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

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiBase = String.fromEnvironment(
  'API_BASE_URL',
  // If you're running backend on your laptop & device is Android emulator, use 10.0.2.2
  // For physical device on same Wi-Fi, use your laptop’s LAN IP like http://192.168.1.8:4000
  defaultValue: 'http://192.168.1.8:4000',
);

class Api {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  String _friendlyError(Object err) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map && data['message'] is String)
        return data['message'] as String;
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout) {
        return 'Server timeout. Check network/API base URL.';
      }
      if (err.type == DioExceptionType.connectionError) {
        return 'Cannot reach server at $apiBase';
      }
      return 'Request failed';
    }
    return 'Unexpected error';
  }

  Future<Dio> _authed() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    final d = _dio;
    if (t != null) d.options.headers['Authorization'] = 'Bearer $t';
    return d;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final r = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = r.data['accessToken'] as String?;
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return Map<String, dynamic>.from(r.data);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final d = await _authed();
      final r = await d.get('/users/me');
      return Map<String, dynamic>.from(r.data);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<List<dynamic>> listConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final d = await _authed();
      final r = await d.get(
        '/conversations',
        queryParameters: {'page': page, 'limit': limit},
      );
      return r.data as List<dynamic>;
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String text,
  ) async {
    try {
      final d = await _authed();
      final r = await d.post(
        '/messages',
        data: {'conversationId': conversationId, 'text': text},
      );
      return Map<String, dynamic>.from(r.data);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  Future<Map<String, dynamic>> createConversation({
    String? name,
    List<String>? participants,
  }) async {
    try {
      final d = await _authed();
      final r = await d.post(
        '/conversations',
        data: {
          'name': name,
          // backend accepts array; empty array means only you will be a participant
          'participants': participants ?? <String>[],
        },
      );
      return Map<String, dynamic>.from(r.data);
    } catch (e) {
      throw Exception(_friendlyError(e));
    }
  }
}
