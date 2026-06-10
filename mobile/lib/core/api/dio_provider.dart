import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_token_storage_provider.dart';
import '../config/app_config_provider.dart';
import '../router/router_provider.dart';
import 'dio_client.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final authStorage = ref.watch(authTokenStorageProvider);
  final router = ref.read(routerProvider);

  return DioClient.create(
    config: config,
    authStorage: authStorage,
    // onRefreshFailed is invoked from inside the Dio interceptor (off the
    // widget tree). Use Future.microtask to defer go_router navigation so it
    // runs after the current build frame completes.
    onRefreshFailed: () => Future.microtask(() => router.go('/login')),
  );
}
