import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_token_storage.dart';

part 'auth_token_storage_provider.g.dart';

@Riverpod(keepAlive: true)
AuthTokenStorage authTokenStorage(Ref ref) {
  return AuthTokenStorage(const FlutterSecureStorage());
}
