import 'package:dio/dio.dart';
import '../auth/auth_token_storage.dart';
import '../config/app_config.dart';
import 'jwt_interceptor.dart';

abstract final class DioClient {
  static Dio create({
    required AppConfig config,
    required AuthTokenStorage authStorage,
    required void Function() onRefreshFailed,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    );

    // Bare Dio instance used only for token refresh — no interceptors,
    // so a 401 on the refresh endpoint won't recurse into JwtInterceptor.
    final refreshDio = Dio(baseOptions);

    final dio = Dio(baseOptions);

    dio.interceptors.add(
      JwtInterceptor(
        authStorage: authStorage,
        refreshDio: refreshDio,
        refreshPath: '/api/auth/refresh',
        onRefreshFailed: onRefreshFailed,
      ),
    );

    if (config.isDevFlavor) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
