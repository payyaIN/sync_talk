import 'package:dio/dio.dart';
import 'package:sync_talk_mobile/core/utils/secure_token_store.dart';
import '../config/app_env.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  factory DioClient() => _i;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  void init() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureTokenStore.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    // Optional logger in debug:
    // dio.interceptors.add(PrettyDioLogger());
  }
}
