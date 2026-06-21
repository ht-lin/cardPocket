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

    test('sends expiresAt as ISO8601 and parses it back', () async {
      final expiry = DateTime.utc(2027, 1, 1);
      final json = Map<String, dynamic>.from(_cardJson)
        ..['expiresAt'] = '2027-01-01T00:00:00.000Z';
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: json,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/api/cards'),
        ),
      );

      final result = await repo.create(
        name: 'Costco',
        barcodeType: 'QR_CODE',
        barcodeContent: '12345',
        expiresAt: expiry,
      );

      expect(result.expiresAt!.isAtSameMomentAs(expiry), true);

      final captured = verify(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((captured.first as Map)['expiresAt'], '2027-01-01T00:00:00.000Z');

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.first.expiresAt!.isAtSameMomentAs(expiry), true);
    });

    test('omits expiresAt from payload when null', () async {
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

      await repo.create(
        name: 'Costco',
        barcodeType: 'QR_CODE',
        barcodeContent: '12345',
      );

      final captured = verify(
        () => mockDio.post<Map<String, dynamic>>(
          '/api/cards',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect((captured.first as Map).containsKey('expiresAt'), false);
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

  group('CardsRepository.updateCard', () {
    setUp(() async {
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
    });

    test('updates name + expiresAt and writes DB on 200', () async {
      final expiry = DateTime.utc(2027, 1, 1);
      final updatedJson = Map<String, dynamic>.from(_cardJson)
        ..['name'] = 'New Name'
        ..['expiresAt'] = '2027-01-01T00:00:00.000Z';

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

      final result = await repo.updateCard(
        id: 'card-1',
        name: 'New Name',
        expiresAt: expiry,
      );
      expect(result.name, 'New Name');
      expect(result.expiresAt!.isAtSameMomentAs(expiry), true);

      final captured = verify(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/cards/card-1',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      final body = captured.first as Map;
      expect(body['name'], 'New Name');
      expect(body['expiresAt'], '2027-01-01T00:00:00.000Z');

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.first.name, 'New Name');
      expect(rows.first.expiresAt!.isAtSameMomentAs(expiry), true);
    });

    test('clears expiresAt by sending null', () async {
      final updatedJson = Map<String, dynamic>.from(_cardJson)
        ..['expiresAt'] = null;

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

      final result = await repo.updateCard(
        id: 'card-1',
        name: 'Costco',
        expiresAt: null,
      );
      expect(result.expiresAt, isNull);

      final captured = verify(
        () => mockDio.patch<Map<String, dynamic>>(
          '/api/cards/card-1',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      final body = captured.first as Map;
      expect(body.containsKey('expiresAt'), true);
      expect(body['expiresAt'], isNull);
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

  group('CardsRepository.searchLocal', () {
    setUp(() async {
      await db.upsertCards([
        CardsTableCompanion.insert(
          id: 'c1',
          name: 'Costco Membership',
          barcodeType: 'QR_CODE',
          barcodeContent: 'abc',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 3),
        ),
        CardsTableCompanion.insert(
          id: 'c2',
          name: 'Starbucks',
          barcodeType: 'CODE_128',
          barcodeContent: 'xyz',
          isOwner: false,
          updatedAt: DateTime(2026, 6, 2),
        ),
        CardsTableCompanion.insert(
          id: 'c3',
          name: '50% off coupon',
          barcodeType: 'QR_CODE',
          barcodeContent: '111',
          isOwner: true,
          updatedAt: DateTime(2026, 6, 1),
        ),
      ]);
    });

    test('matches by case-insensitive substring', () async {
      final results = await repo.searchLocal('cost');
      expect(results.map((c) => c.id), ['c1']);
    });

    test('matches owned and viewed cards together', () async {
      // both names contain lowercase "s"
      final results = await repo.searchLocal('s');
      expect(results.map((c) => c.id), containsAll(['c1', 'c2']));
    });

    test('treats % as a literal character, not a wildcard', () async {
      final results = await repo.searchLocal('%');
      expect(results.map((c) => c.id), ['c3']);
    });

    test('returns empty list when nothing matches', () async {
      final results = await repo.searchLocal('zzz');
      expect(results, isEmpty);
    });
  });

  group('CardsRepository.searchRemote', () {
    test('parses member array and upserts results to DB', () async {
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

      final results = await repo.searchRemote('Costco');
      expect(results.map((c) => c.id), ['card-1']);

      final rows = await db.getOwnedCards(offset: 0);
      expect(rows.length, 1);
      expect(rows.first.id, 'card-1');
    });

    test('passes q query parameter', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'member': <Map<String, dynamic>>[], 'totalItems': 0},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/cards'),
        ),
      );

      await repo.searchRemote('Costco');
      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      expect((captured.first as Map)['q'], 'Costco');
    });

    test('maps network failures to NetworkException', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          '/api/cards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/cards'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repo.searchRemote('Costco'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
