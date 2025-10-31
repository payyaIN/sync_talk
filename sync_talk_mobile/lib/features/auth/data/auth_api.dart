// import 'package:dio/dio.dart';
// import '../../../core/config/dio_client.dart';

// class AuthApi {
//   final Dio _dio = DioClient().dio;

//   Future<Map<String, dynamic>> register(String name, String email, String password) async {
//     final res = await _dio.post('/auth/register', data: {
//       'name': name, 'email': email, 'password': password,
//     });
//     return res.data as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final res = await _dio.post('/auth/login', data: {
//       'email': email, 'password': password,
//     });
//     return res.data as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> me() async {
//     final res = await _dio.get('/users/me');
//     return res.data as Map<String, dynamic>;
//   }
// }

import 'package:dio/dio.dart';
import '../../../core/config/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/users/me');
    return res.data as Map<String, dynamic>;
  }
}
