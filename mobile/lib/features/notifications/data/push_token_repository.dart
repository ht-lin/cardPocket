import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/dio_provider.dart';

part 'push_token_repository.g.dart';

@Riverpod(keepAlive: true)
PushTokenRepository pushTokenRepository(Ref ref) =>
    PushTokenRepository(ref.watch(dioProvider));

/// Registers the device's FCM token with the backend so it can receive pushes.
class PushTokenRepository {
  const PushTokenRepository(this._dio);

  final Dio _dio;

  /// Idempotently upserts [fcmToken] for the current user via
  /// `POST /api/auth/push-token`. Registration failures are swallowed —
  /// missing a token registration must never block the user flow; the next
  /// `onTokenRefresh` or app launch will retry.
  Future<void> register(String fcmToken) async {
    try {
      await _dio.post<void>(
        '/api/auth/push-token',
        data: {'fcmToken': fcmToken, 'platform': _platform},
      );
    } on DioException {
      // Best-effort; ignore.
    }
  }

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';
}
