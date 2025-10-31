import '../../../core/services/api.dart';
import '../../../core/services/session.dart';

class AuthRepo {
  Future<void> login(String email, String password) async {
    final resp = await dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    session.setTokens(resp.data['accessToken'], resp.data['refreshToken']);
    session.userId = resp.data['user']['id'];
    await session.save();
  }

  Future<void> register(String name, String email, String password) async {
    await dio.post(
      '/api/auth/register',
      data: {'displayName': name, 'email': email, 'password': password},
    );
  }

  Future<void> loginWithGoogle(String idToken) async {
    final resp = await dio.post('/api/auth/google', data: {'idToken': idToken});
    session.setTokens(resp.data['accessToken'], resp.data['refreshToken']);
    session.userId = resp.data['user']['id'];
    await session.save();
  }

  //   Future<void> loginWithGoogle(String idToken) async {
  //   final res = await dio.post('/api/auth/google', data: {
  //     'idToken': idToken,
  //   });

  //   // Save access + refresh tokens
  //   final data = res.data;
  //   session.accessToken = data['accessToken'];
  //   session.userId = data['user']['_id'];

  //   // Attach token to all future requests
  //   dio.options.headers['Authorization'] = 'Bearer ${session.accessToken}';
  // }
}

final authRepo = AuthRepo();
