
import 'package:dio/dio.dart';

class Api {
  final Dio dio;
  Api._internal(this.dio);
  static final Api _instance = Api._internal(Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_BASE', defaultValue: 'https://sync-talk-backend-4ubc.onrender.com'))));
  factory Api() => _instance;

  void setToken(String? token) { dio.options.headers['Authorization'] = token != null ? 'Bearer $token' : null; }

  Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => dio.get(path, queryParameters: queryParameters);
}
final api = Api();
