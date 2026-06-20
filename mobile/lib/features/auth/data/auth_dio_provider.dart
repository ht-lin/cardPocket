import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/config/app_config_provider.dart';
// import 'dart:io';
// import 'package:dio/io.dart';

part 'auth_dio_provider.g.dart';

// Bare Dio instance for auth endpoints — no JWT interceptor so a 401 on
// login (wrong credentials) does not trigger a spurious token refresh.
@Riverpod(keepAlive: true)
Dio authDio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      // Pin the response format to JSON-LD for consistency with the rest of
      // the app; fromJson ignores the extra @context/@id/@type keys.
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/ld+json',
      },
    ),
  );
  // if (config.isDevFlavor) {
  //     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  //         final c = HttpClient();
  //         c.badCertificateCallback = (cert, host, port) => true;
  //         return c;
  //     };
  // }
  // return dio;
}
