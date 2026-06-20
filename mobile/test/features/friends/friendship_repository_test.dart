import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/features/friends/data/friendship_repository.dart';

class MockDio extends Mock implements Dio {}

const _friendshipJson = {
  'id': 'fs-1',
  'friend': {'id': 'user-2', 'userName': 'jane_doe'},
  'createdAt': '2026-06-01T10:00:00Z',
};

const _requestJson = {
  'id': 'req-1',
  'requester': {'id': 'user-3', 'userName': 'john_doe'},
  'createdAt': '2026-06-01T11:00:00Z',
};

const _userJson = {'id': 'user-4', 'userName': 'alice'};

void main() {
  late MockDio mockDio;
  late FriendshipRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = FriendshipRepository(mockDio);
  });

  group('FriendshipRepository.getFriends', () {
    test('returns list of Friendship on 200', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/api/friendships'))
          .thenAnswer(
        (_) async => Response(
          data: {
            'member': [_friendshipJson],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/friendships'),
        ),
      );

      final result = await repo.getFriends();

      expect(result.length, 1);
      expect(result.first.id, 'fs-1');
      expect(result.first.friend.userName, 'jane_doe');
    });

    test('throws NetworkException on connection timeout', () async {
      when(() => mockDio.get<Map<String, dynamic>>('/api/friendships'))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/friendships'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(() => repo.getFriends(), throwsA(isA<NetworkException>()));
    });
  });

  group('FriendshipRepository.getPendingRequests', () {
    test('returns list of FriendRequest on 200', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('/api/friendships/requests'),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'member': [_requestJson],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/friendships/requests'),
        ),
      );

      final result = await repo.getPendingRequests();

      expect(result.length, 1);
      expect(result.first.id, 'req-1');
      expect(result.first.requester.userName, 'john_doe');
    });
  });

  group('FriendshipRepository.sendRequest', () {
    test('completes without error on 201', () async {
      when(
        () => mockDio.post<void>(
          '/api/friendships',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/friendships'),
        ),
      );

      await expectLater(repo.sendRequest('user-5'), completes);
    });

    test('throws UnprocessableException on 422', () async {
      when(
        () => mockDio.post<void>(
          '/api/friendships',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {'propertyPath': 'addresseeId', 'message': 'Already friends'},
              ],
            },
            requestOptions: RequestOptions(path: '/api/friendships'),
          ),
          requestOptions: RequestOptions(path: '/api/friendships'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.sendRequest('user-5'),
        throwsA(
          isA<UnprocessableException>().having(
            (e) => e.errors['addresseeId'],
            'addresseeId error',
            contains('Already friends'),
          ),
        ),
      );
    });
  });

  group('FriendshipRepository.acceptRequest', () {
    test('completes without error on 200', () async {
      when(
        () => mockDio.patch<void>('/api/friendships/req-1/accept'),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions:
              RequestOptions(path: '/api/friendships/req-1/accept'),
        ),
      );

      await expectLater(repo.acceptRequest('req-1'), completes);
    });
  });

  group('FriendshipRepository.deleteOrReject', () {
    test('completes without error on 204', () async {
      when(
        () => mockDio.delete<void>('/api/friendships/fs-1'),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/api/friendships/fs-1'),
        ),
      );

      await expectLater(repo.deleteOrReject('fs-1'), completes);
    });

    test('throws ForbiddenException on 403', () async {
      when(
        () => mockDio.delete<void>('/api/friendships/fs-1'),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 403,
            requestOptions: RequestOptions(path: '/api/friendships/fs-1'),
          ),
          requestOptions: RequestOptions(path: '/api/friendships/fs-1'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.deleteOrReject('fs-1'),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('FriendshipRepository.searchUsers', () {
    test('returns list of UserSummary on 200', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/users/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'member': [_userJson],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/search'),
        ),
      );

      final result = await repo.searchUsers('alice');

      expect(result.length, 1);
      expect(result.first.userName, 'alice');
    });

    test('returns empty list when no matches', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/users/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'member': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/users/search'),
        ),
      );

      final result = await repo.searchUsers('nonexistent');
      expect(result, isEmpty);
    });

    test('throws ServerException on 500', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/users/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/users/search'),
          ),
          requestOptions: RequestOptions(path: '/api/users/search'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repo.searchUsers('q'), throwsA(isA<ServerException>()));
    });
  });
}
