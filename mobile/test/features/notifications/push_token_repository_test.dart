import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/features/notifications/data/push_token_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late PushTokenRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = PushTokenRepository(mockDio);
  });

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Response<void> okResponse() => Response<void>(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/auth/push-token'),
      );

  group('PushTokenRepository.register', () {
    test('posts token with ANDROID platform on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      when(
        () => mockDio.post<void>(
          '/api/auth/push-token',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => okResponse());

      await repo.register('token-abc');

      final captured = verify(
        () => mockDio.post<void>(
          '/api/auth/push-token',
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured['fcmToken'], 'token-abc');
      expect(captured['platform'], 'ANDROID');
    });

    test('uses IOS platform on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(
        () => mockDio.post<void>(
          '/api/auth/push-token',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => okResponse());

      await repo.register('token-ios');

      final captured = verify(
        () => mockDio.post<void>(
          '/api/auth/push-token',
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured['platform'], 'IOS');
    });

    test('swallows DioException so registration never blocks the user',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      when(
        () => mockDio.post<void>(
          '/api/auth/push-token',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/push-token'),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(repo.register('token-x'), completes);
    });
  });
}
