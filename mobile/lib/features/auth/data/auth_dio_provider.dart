import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/config/app_config_provider.dart';

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
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
