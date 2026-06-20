import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/core/api/api_exception.dart';
import 'package:card_pocket/core/database/app_database.dart';
import 'package:card_pocket/features/cards/data/cards_repository.dart';

class MockDio extends Mock implements Dio {}

AppDatabase _inMemoryDb() => AppDatabase(NativeDatabase.memory());

final _cardJson = {
  'id': 'card-1',
  'name': 'Costco',
  'barcodeType': 'QR_CODE',
  'barcodeContent': '12345',
  'isOwner': true,
  'viewerNickname': null,
  'owner': {'id': 'user-1', 'userName': 'john_doe'},
  'updatedAt': '2026-06-01T10:00:00.000Z',
};

void main() {
  late MockDio mockDio;
  late AppDatabase db;
  late CardsRepository repo;

  setUp(() {
    mockDio = MockDio();
    db = _inMemoryDb();
    repo = CardsRepository(mockDio, db);
  });

  tearDown(() => db.close());

  group('CardsRepository.create', () {
    test('returns CardModel and upserts to DB on 201', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _cardJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/cards'),
        ),
      );

      final result = await repo.create(
        name: 'Costco',
        barcodeType: 'QR_CODE',
        barcodeContent: '12345',
      );

      expect(result.name, 'Costco');
      expect(result.isOwner, true);
      expect(result.ownerUsername, 'john_doe');

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.length, 1);
      expect(rows.first.id, 'card-1');
    });

    test('throws UnprocessableException on 422', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          response: Response(
            statusCode: 422,
            data: {
              'violations': [
                {'propertyPath': 'name', 'message': 'Name too long'},
              ],
            },
            requestOptions: RequestOptions(path: '/api/cards'),
          ),
          requestOptions: RequestOptions(path: '/api/cards'),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => repo.create(
          name: 'x' * 300,
          barcodeType: 'QR_CODE',
          barcodeContent: '12345',
        ),
        throwsA(
          isA<UnprocessableException>().having(
            (e) => e.errors['name'],
            'name error',
            contains('Name too long'),
          ),
        ),
      );
    });

    test('throws NetworkException on connection timeout', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/cards'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repo.create(
          name: 'Costco',
          barcodeType: 'QR_CODE',
          barcodeContent: '12345',
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('CardsRepository.updateName', () {
    test('returns updated CardModel and updates DB on 200', () async {
      await db.upsertCards([
        CardsTableCompanion.insert(
          id: 'card-1',
          name: 'Old Name',
          barcodeType: 'QR_CODE',
          barcodeContent: '12345',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 1),
        ),
      ]);

      final updatedJson = Map<String, dynamic>.from(_cardJson)
        ..['name'] = 'New Name';

      when(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/cards/card-1',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: updatedJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards/card-1'),
        ),
      );

      final result = await repo.updateName('card-1', 'New Name');
      expect(result.name, 'New Name');

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.first.name, 'New Name');
    });
  });

  group('CardsRepository.delete', () {
    test('deletes from DB on 204', () async {
      await db.upsertCards([
        CardsTableCompanion.insert(
          id: 'card-1',
          name: 'Costco',
          barcodeType: 'QR_CODE',
          barcodeContent: '12345',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 1),
        ),
      ]);

      when(
        () => mockDio.delete<void>('/api/cards/card-1'),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/api/cards/card-1'),
        ),
      );

      await repo.delete('card-1');
      final rows = await db.getOwnedCards(offset: 0);
      expect(rows, isEmpty);
    });
  });

  group('CardsRepository.syncCards (full sync)', () {
    test('upserts returned cards to DB', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'member': [_cardJson],
            'totalItems': 1,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards'),
        ),
      );

      await repo.syncCards();

      final owned = await repo.getOwnedCards(0);
      expect(owned.length, 1);
      expect(owned.first.id, 'card-1');
    });

    test('runs incremental sync when lastSyncAt exists', () async {
      await db.setLastSyncAt(DateTime(2026, 6, 1));

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/sync',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'updated': <Map<String, dynamic>>[],
            'deleted': <String>[],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards/sync'),
        ),
      );

      await repo.syncCards();
      // Verify the request included updatedAfter
      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/sync',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      final params = captured.first as Map<String, dynamic>;
      expect(params.containsKey('updatedAfter'), true);
    });

    test('deletes removed cards in incremental sync', () async {
      await db.upsertCards([
        CardsTableCompanion.insert(
          id: 'card-to-delete',
          name: 'Old',
          barcodeType: 'QR_CODE',
          barcodeContent: '999',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 1),
        ),
      ]);
      await db.setLastSyncAt(DateTime(2026, 6, 1));

      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards/sync',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'updated': <Map<String, dynamic>>[],
            'deleted': <String>['card-to-delete'],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards/sync'),
        ),
      );

      await repo.syncCards();
      final owned = await db.getOwnedCards(offset: 0);
      expect(owned, isEmpty);
    });
  });

  group('CardsRepository local reads', () {
    setUp(() async {
      await db.upsertCards([
        CardsTableCompanion.insert(
          id: 'owned-1',
          name: 'My Card',
          barcodeType: 'QR_CODE',
          barcodeContent: 'abc',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 2),
        ),
        CardsTableCompanion.insert(
          id: 'viewed-1',
          name: 'Shared Card',
          barcodeType: 'CODE_128',
          barcodeContent: 'xyz',
          isOwner: false,
          updatedAt: DateTime(2026, 6, 1),
        ),
      ]);
    });

    test('getOwnedCards returns only owned cards', () async {
      final cards = await repo.getOwnedCards(0);
      expect(cards.length, 1);
      expect(cards.first.isOwner, true);
    });

    test('getViewedCards returns only viewed cards', () async {
      final cards = await repo.getViewedCards(0);
      expect(cards.length, 1);
      expect(cards.first.isOwner, false);
    });

    test('getCardById returns the correct card', () async {
      final card = await repo.getCardById('owned-1');
      expect(card?.name, 'My Card');
    });

    test('getCardById returns null for unknown id', () async {
      final card = await repo.getCardById('unknown');
      expect(card, isNull);
    });
  });
}
