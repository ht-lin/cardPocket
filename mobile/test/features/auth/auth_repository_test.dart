import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/features/auth/data/auth_repository.dart';
import 'package:card_pocket/features/auth/domain/auth_models.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = AuthRepository(mockDio);
  });

  group('AuthRepository.login', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('returns AuthTokens on 200', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'access_token': 'access',
            'refresh_token': 'refresh',
            'token_type': 'Bearer',
            'expires_in': 900,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/auth/login'),
        ),
      );

      final result = await repository.login(email, password);
      expect(result.accessToken, 'access');
      expect(result.refreshToken, 'refresh');
    });

    test('throws UnauthorizedException on 401', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/api/auth/login'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.login(email, password),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('throws UnprocessableException with field errors on 422', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {'propertyPath': 'email', 'message': 'Invalid email'},
              ],
            },
            requestOptions: RequestOptions(path: '/api/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/api/auth/login'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.login(email, password),
        throwsA(
          isA<UnprocessableException>().having(
            (e) => e.errors['email'],
            'email error',
            contains('Invalid email'),
          ),
        ),
      );
    });

    test('throws NetworkException on connection timeout', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/login',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.login(email, password),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('AuthRepository.register', () {
    const request = RegisterRequest(
      email: 'new@example.com',
      password: 'password123',
      userName: 'newuser',
      gdprConsent: true,
    );

    test('returns User on 201', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/register',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'id': 'uuid-123',
            'email': 'new@example.com',
            'userName': 'newuser',
            'emailVerified': false,
            'createdAt': '2026-06-01T10:00:00.000Z',
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/auth/register'),
        ),
      );

      final result = await repository.register(request);
      expect(result.email, 'new@example.com');
      expect(result.emailVerified, false);
    });

    test('throws UnprocessableException on 422', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/auth/register',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {'propertyPath': 'userName', 'message': 'Username taken'},
              ],
            },
            requestOptions: RequestOptions(path: '/api/auth/register'),
          ),
          requestOptions: RequestOptions(path: '/api/auth/register'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repository.register(request),
        throwsA(isA<UnprocessableException>()),
      );
    });
  });

  group('AuthRepository.logout', () {
    test('completes successfully on 204', () async {
      when(
        () => mockDio.post<void>(
          '/api/auth/logout',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/api/auth/logout'),
        ),
      );

      await expectLater(repository.logout('refresh-token'), completes);
    });
  });

  group('AuthRepository.resendVerification', () {
    test('completes successfully on 200', () async {
      when(
        () => mockDio.post<void>(
          '/api/auth/resend-verification',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions:
              RequestOptions(path: '/api/auth/resend-verification'),
        ),
      );

      await expectLater(
        repository.resendVerification('user@example.com'),
        completes,
      );
    });
  });
}
