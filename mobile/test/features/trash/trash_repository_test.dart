import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/core/database/app_database.dart';
import 'package:card_pocket/features/trash/data/trash_repository.dart';

class MockDio extends Mock implements Dio {}

AppDatabase _inMemoryDb() => AppDatabase(NativeDatabase.memory());

final _trashJson = {
  'id': 'card-1',
  'name': 'Costco',
  'barcodeType': 'QR_CODE',
  'barcodeContent': '12345',
  'isOwner': true,
  'createdAt': '2026-05-01T10:00:00.000Z',
  'updatedAt': '2026-06-01T10:00:00.000Z',
  'expiresAt': null,
  'color': null,
  'deletedAt': '2026-06-10T10:00:00.000Z',
};

final _restoredJson = {
  'id': 'card-1',
  'name': 'Costco',
  'barcodeType': 'QR_CODE',
  'barcodeContent': '12345',
  'isOwner': true,
  'viewerNickname': null,
  'owner': {'id': 'user-1', 'userName': 'john_doe'},
  'updatedAt': '2026-06-21T10:00:00.000Z',
};

void main() {
  late MockDio mockDio;
  late AppDatabase db;
  late TrashRepository repo;

  setUp(() {
    mockDio = MockDio();
    db = _inMemoryDb();
    repo = TrashRepository(mockDio, db);
  });

  tearDown(() => db.close());

  group('TrashRepository.getTrash', () {
    test('parses Hydra member array into TrashCard with deletedAt', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/trash',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'member': [_trashJson],
            'totalItems': 1,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards/trash'),
        ),
      );

      final result = await repo.getTrash(0);

      expect(result.length, 1);
      expect(result.first.id, 'card-1');
      expect(result.first.name, 'Costco');
      expect(
        result.first.deletedAt.isAtSameMomentAs(
          DateTime.utc(2026, 6, 10, 10),
        ),
        true,
      );
    });

    test('sends page derived from offset', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/trash',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'member': <Map<String, dynamic>>[], 'totalItems': 0},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards/trash'),
        ),
      );

      await repo.getTrash(40);

      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/trash',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect((captured.first as Map)['page'], 3);
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/trash',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/cards/trash'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(() => repo.getTrash(0), throwsA(isA<NetworkException>()));
    });
  });

  group('TrashRepository.restore', () {
    test('upserts the restored card back into the local cards table',
        () async {
      when(
        () => mockDio.post<Map<String, dynamic>>('/api/cards/card-1/restore'),
      ).thenAnswer(
        (_) async => Response(
          data: _restoredJson,
          statusCode: 200,
          requestOptions:
              RequestOptions(path: '/api/cards/card-1/restore'),
        ),
      );

      await repo.restore('card-1');

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.length, 1);
      expect(rows.first.id, 'card-1');
      expect(rows.first.isOwner, true);
    });

    test('maps 404 to NotFoundException', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>('/api/cards/card-1/restore'),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions:
                RequestOptions(path: '/api/cards/card-1/restore'),
          ),
          requestOptions: RequestOptions(path: '/api/cards/card-1/restore'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => repo.restore('card-1'), throwsA(isA<NotFoundException>()));
    });
  });

  group('TrashRepository.permanentDelete', () {
    test('sends DELETE to the permanent endpoint', () async {
      when(
        () => mockDio.delete<void>('/api/cards/card-1/permanent'),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions:
              RequestOptions(path: '/api/cards/card-1/permanent'),
        ),
      );

      await repo.permanentDelete('card-1');

      verify(() => mockDio.delete<void>('/api/cards/card-1/permanent'))
          .called(1);
    });

    test('maps 403 to ForbiddenException', () async {
      when(
        () => mockDio.delete<void>('/api/cards/card-1/permanent'),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 403,
            requestOptions:
                RequestOptions(path: '/api/cards/card-1/permanent'),
          ),
          requestOptions:
              RequestOptions(path: '/api/cards/card-1/permanent'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.permanentDelete('card-1'),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
