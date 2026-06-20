import 'package:dio/dio.dart';
import '../auth/auth_token_storage.dart';
import '../config/app_config.dart';
import 'jwt_interceptor.dart';
import 'dart:io';
import 'package:dio/io.dart';

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
      // Content-Type describes the request body; Accept pins the response
      // format. Without Accept, API Platform falls back to its default format
      // and may return a bare JSON array for collections, which breaks the
      // Hydra (member/totalItems) parsing in the repositories.
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/ld+json',
      },
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
      // dev-only: 信任 Symfony 本地自签证书（勿用于 prod，已被 isDevFlavor 门控）
      // for (final d in [dio, refreshDio]) {
      //     (d.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      //         final c = HttpClient();
      //         c.badCertificateCallback = (cert, host, port) => true;
      //         return c;
      //     };
      // }
    }

    return dio;
  }
}
