
import 'package:dio/dio.dart';

class Api {
  final Dio dio;
  Api._internal(this.dio);
  static final Api _instance = Api._internal(Dio(BaseOptions(baseUrl: const String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:4000'))));
  factory Api() => _instance;

  String? _accessToken;
  void setToken(String? token) { _accessToken = token; dio.options.headers['Authorization'] = token != null ? 'Bearer $token' : null; }

  Future<Response> post(String path, {dynamic data}) => dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => dio.get(path, queryParameters: queryParameters);
}
final api = Api();
