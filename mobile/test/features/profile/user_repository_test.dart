import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/features/auth/domain/auth_models.dart';
import 'package:card_pocket/features/profile/data/user_repository.dart';

class MockDio extends Mock implements Dio {}

const _userJson = {
  'id': 'user-1',
  'email': 'alice@example.com',
  'userName': 'alice',
  'emailVerified': true,
  'createdAt': '2026-06-01T10:00:00.000Z',
};

void main() {
  late MockDio mockDio;
  late UserRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = UserRepository(mockDio);
  });

  group('UserRepository.getProfile', () {
    test('returns User on 200', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/api/users/me')).thenAnswer(
        (_) async => Response(
          data: _userJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.getProfile();

      expect(user.id, 'user-1');
      expect(user.email, 'alice@example.com');
      expect(user.userName, 'alice');
      expect(user.emailVerified, isTrue);
      // Field omitted by backend → defaults to keep.
      expect(user.expiryPolicy, ExpiryPolicy.keep);
    });

    test('parses AUTO_TRASH expiryPolicy', () async {
      final json = {..._userJson, 'expiryPolicy': 'AUTO_TRASH'};
      when(() => mockDio.get<Map<String, dynamic>>('/api/users/me')).thenAnswer(
        (_) async => Response(
          data: json,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.getProfile();
      expect(user.expiryPolicy, ExpiryPolicy.autoTrash);
    });

    test('throws NetworkException on connection timeout', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/api/users/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(() => repo.getProfile(), throwsA(isA<NetworkException>()));
    });

    test('throws UnauthorizedException on 401', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/api/users/me')).thenThrow(
        DioException(
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/users/me'),
          ),
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repo.getProfile(), throwsA(isA<UnauthorizedException>()));
    });
  });

  group('UserRepository.updateUsername', () {
    test('returns updated User on 200', () async {
      final updatedJson = {..._userJson, 'userName': 'alice_new'};
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: updatedJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.updateUsername('alice_new');

      expect(user.userName, 'alice_new');
    });

    test('throws UnprocessableException with field error on 422', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {'propertyPath': 'userName', 'message': 'Username already taken'},
              ],
            },
            requestOptions: RequestOptions(path: '/api/users/me'),
          ),
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.updateUsername('taken'),
        throwsA(
          isA<UnprocessableException>().having(
            (e) => e.errors['userName'],
            'userName error',
            contains('Username already taken'),
          ),
        ),
      );
    });
  });

  group('UserRepository.updatePassword', () {
    test('returns updated User on 200', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _userJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.updatePassword(
        currentPassword: 'old123456',
        newPassword: 'new123456',
      );

      expect(user.id, 'user-1');
    });

    test('throws UnprocessableException on wrong current password', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {
                  'propertyPath': 'currentPassword',
                  'message': 'Current password is incorrect',
                },
              ],
            },
            requestOptions: RequestOptions(path: '/api/users/me'),
          ),
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.updatePassword(
          currentPassword: 'wrong',
          newPassword: 'new123456',
        ),
        throwsA(
          isA<UnprocessableException>().having(
            (e) => e.errors['currentPassword'],
            'currentPassword error',
            contains('Current password is incorrect'),
          ),
        ),
      );
    });
  });

  group('UserRepository.updateExpiryPolicy', () {
    test('sends AUTO_TRASH and returns updated User', () async {
      final json = {..._userJson, 'expiryPolicy': 'AUTO_TRASH'};
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: json,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.updateExpiryPolicy(ExpiryPolicy.autoTrash);
      expect(user.expiryPolicy, ExpiryPolicy.autoTrash);

      final captured = verify(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((captured.first as Map)['expiryPolicy'], 'AUTO_TRASH');
    });

    test('sends KEEP for the keep policy', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _userJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      await repo.updateExpiryPolicy(ExpiryPolicy.keep);

      final captured = verify(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((captured.first as Map)['expiryPolicy'], 'KEEP');
    });
  });

  group('UserRepository.updateDiscoverable', () {
    test('sends discoverable flag and returns updated User', () async {
      final json = {..._userJson, 'discoverable': false};
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: json,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.updateDiscoverable(false);
      expect(user.discoverable, isFalse);

      final captured = verify(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((captured.first as Map)['discoverable'], false);
    });

    test('defaults to discoverable=true when backend omits the field', () async {
      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/users/me',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _userJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      final user = await repo.updateDiscoverable(true);
      expect(user.discoverable, isTrue);
    });
  });

  group('UserRepository.exportData', () {
    test('returns the raw export map on 200', () async {
      final export = {
        'profile': {'email': 'alice@example.com'},
        'ownedCards': [],
        'friends': [],
      };
      when(
        () => mockDio
            .get<Map<String, dynamic>>('/api/users/me/data-export'),
      ).thenAnswer(
        (_) async => Response(
          data: export,
          statusCode: 200,
          requestOptions:
              RequestOptions(path: '/api/users/me/data-export'),
        ),
      );

      final data = await repo.exportData();
      expect(data['profile'], {'email': 'alice@example.com'});
    });

    test('throws UnauthorizedException on 401', () async {
      when(
        () => mockDio
            .get<Map<String, dynamic>>('/api/users/me/data-export'),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 401,
            requestOptions:
                RequestOptions(path: '/api/users/me/data-export'),
          ),
          requestOptions:
              RequestOptions(path: '/api/users/me/data-export'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repo.exportData(), throwsA(isA<UnauthorizedException>()));
    });
  });

  group('UserRepository.deleteAccount', () {
    test('completes without error on 204', () async {
      when(() => mockDio.delete<void>('/api/users/me')).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/api/users/me'),
        ),
      );

      await expectLater(repo.deleteAccount(), completes);
    });

    test('throws ServerException on 500', () async {
      when(() => mockDio.delete<void>('/api/users/me')).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/users/me'),
          ),
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.deleteAccount(),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws NetworkException on receive timeout', () async {
      when(() => mockDio.delete<void>('/api/users/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/users/me'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(
        () => repo.deleteAccount(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
