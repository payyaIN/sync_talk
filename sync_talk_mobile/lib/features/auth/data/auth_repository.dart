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

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();
}
