import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/auth/auth_token_storage_provider.dart';
import '../data/auth_repository.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final storage = ref.watch(authTokenStorageProvider);
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null) return const AuthState.unauthenticated();
    try {
      final tokens =
          await ref.read(authRepositoryProvider).refresh(refreshToken);
      storage.setAccessToken(tokens.accessToken);
      await storage.saveRefreshToken(tokens.refreshToken);
      return _stateFromJwt(tokens.accessToken);
    } catch (_) {
      await storage.clearAll();
      return const AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(authTokenStorageProvider);
      final tokens =
          await ref.read(authRepositoryProvider).login(email, password);
      storage.setAccessToken(tokens.accessToken);
      await storage.saveRefreshToken(tokens.refreshToken);
      return _stateFromJwt(tokens.accessToken);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(authTokenStorageProvider);
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await ref.read(authRepositoryProvider).logout(refreshToken);
      } catch (_) {
        // Best-effort — clear local state regardless of server response.
      }
    }
    await storage.clearAll();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

// Decodes JWT payload without signature verification (client-side read only).
AuthState _stateFromJwt(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return const AuthState.unauthenticated();
  final payload =
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final map = jsonDecode(payload) as Map<String, dynamic>;
  final sub = map['sub'] as String? ?? '';
  final verified = map['email_verified'] as bool? ?? true;
  return verified
      ? AuthState.authenticated(userId: sub)
      : AuthState.unverified(userId: sub);
}
