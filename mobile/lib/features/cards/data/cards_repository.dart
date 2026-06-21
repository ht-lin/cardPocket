import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/card_model.dart';

part 'cards_repository.g.dart';

@Riverpod(keepAlive: true)
CardsRepository cardsRepository(Ref ref) => CardsRepository(
      ref.watch(dioProvider),
      ref.watch(appDatabaseProvider),
    );

class CardsRepository {
  const CardsRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  static const _pageSize = 20;
  static const _syncMaxCards = 200;

  Future<void> syncCards() async {
    try {
      final lastSync = await _db.getLastSyncAt();
      if (lastSync != null) {
        await _incrementalSync(lastSync);
      } else {
        await _fullSync();
      }
      await _db.setLastSyncAt(DateTime.now().toUtc());
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> _fullSync() async {
    var page = 1;
    var fetched = 0;
    while (fetched < _syncMaxCards) {
      final remaining = _syncMaxCards - fetched;
      final limit = remaining < _pageSize ? remaining : _pageSize;
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/cards',
        queryParameters: {'page': page, 'itemsPerPage': limit},
      );
      final data = response.data!;
      final members = (data['member'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (members.isEmpty) break;
      await _db.upsertCards(members.map(_toCompanion).toList());
      fetched += members.length;
      final total = (data['totalItems'] as num?)?.toInt() ?? 0;
      if (fetched >= total) break;
      page++;
    }
  }

  Future<void> _incrementalSync(DateTime since) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/cards/sync',
      queryParameters: {'updatedAfter': since.toIso8601String()},
    );
    final data = response.data!;
    // `/api/cards/sync` is a single-resource operation, so `updated`/`deleted`
    // arrive as flat JSON arrays (not nested Hydra collections).
    final updated = (data['updated'] as List).cast<Map<String, dynamic>>();
    final deleted = (data['deleted'] as List).cast<String>();
    if (updated.isNotEmpty) {
      await _db.upsertCards(updated.map(_toCompanion).toList());
    }
    if (deleted.isNotEmpty) {
      await _db.deleteCardsByIds(deleted);
    }
  }

  Future<CardModel> create({
    required String name,
    required String barcodeType,
    required String barcodeContent,
    DateTime? expiresAt,
    String? color,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/cards',
        data: {
          'name': name,
          'barcodeType': barcodeType,
          'barcodeContent': barcodeContent,
          if (expiresAt != null)
            'expiresAt': expiresAt.toUtc().toIso8601String(),
          'color': ?color,
        },
      );
      final card = _mapCard(response.data!);
      await _db.upsertCards([_toCompanion(response.data!)]);
      return card;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CardModel> updateCard({
    required String id,
    required String name,
    required DateTime? expiresAt,
    required String? color,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/cards/$id',
        data: {
          'name': name,
          // Always sent; null clears the validity period.
          'expiresAt': expiresAt?.toUtc().toIso8601String(),
          // Always sent; null clears the custom color.
          'color': color,
        },
      );
      final card = _mapCard(response.data!);
      await _db.upsertCards([_toCompanion(response.data!)]);
      return card;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<void>('/api/cards/$id');
      await _db.deleteCardsByIds([id]);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<CardModel>> getOwnedCards(int offset) async {
    final rows = await _db.getOwnedCards(offset: offset);
    return rows.map(_fromRow).toList();
  }

  Future<List<CardModel>> getViewedCards(int offset) async {
    final rows = await _db.getViewedCards(offset: offset);
    return rows.map(_fromRow).toList();
  }

  Future<List<CardModel>> searchLocal(String query) async {
    final rows = await _db.searchCards(query);
    return rows.map(_fromRow).toList();
  }

  Future<List<CardModel>> searchRemote(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/cards',
        queryParameters: {'q': query},
      );
      final members =
          (response.data!['member'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
      if (members.isNotEmpty) {
        await _db.upsertCards(members.map(_toCompanion).toList());
      }
      return members.map(_mapCard).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<CardModel?> getCardById(String id) async {
    final row = await (
      _db.select(_db.cardsTable)..where((t) => t.id.equals(id))
    ).getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  CardModel _mapCard(Map<String, dynamic> json) => CardModel(
        id: json['id'] as String,
        name: json['name'] as String,
        barcodeType: json['barcodeType'] as String,
        barcodeContent: json['barcodeContent'] as String,
        isOwner: json['isOwner'] as bool,
        shareId: json['shareId'] as String?,
        viewerNickname: json['viewerNickname'] as String?,
        ownerUsername:
            (json['owner'] as Map<String, dynamic>?)?['userName'] as String?,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        color: json['color'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  CardsTableCompanion _toCompanion(Map<String, dynamic> json) =>
      CardsTableCompanion(
        id: Value(json['id'] as String),
        name: Value(json['name'] as String),
        barcodeType: Value(json['barcodeType'] as String),
        barcodeContent: Value(json['barcodeContent'] as String),
        isOwner: Value(json['isOwner'] as bool),
        shareId: Value(json['shareId'] as String?),
        viewerNickname: Value(json['viewerNickname'] as String?),
        ownerUsername: Value(
          (json['owner'] as Map<String, dynamic>?)?['userName'] as String?,
        ),
        expiresAt: Value(
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
        ),
        color: Value(json['color'] as String?),
        updatedAt: Value(DateTime.parse(json['updatedAt'] as String)),
      );

  CardModel _fromRow(CardsTableData row) => CardModel(
        id: row.id,
        name: row.name,
        barcodeType: row.barcodeType,
        barcodeContent: row.barcodeContent,
        isOwner: row.isOwner,
        shareId: row.shareId,
        viewerNickname: row.viewerNickname,
        ownerUsername: row.ownerUsername,
        expiresAt: row.expiresAt,
        color: row.color,
        updatedAt: row.updatedAt,
      );

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    switch (status) {
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 422:
        final errors = _parse422(e.response?.data);
        return UnprocessableException(errors);
      default:
        if (status != null && status >= 500) return const ServerException();
        // A response arrived but decoding/casting it failed (e.g. a response
        // shape that doesn't match what we parse) — that's a contract/format
        // mismatch, not a connectivity problem. Don't mask it as a network
        // error, otherwise the real cause stays hidden behind "check your
        // connection".
        if (status != null) {
          return ServerException('Unexpected response: ${e.message}');
        }
        return NetworkException(e.message ?? 'Unknown error');
    }
  }

  Map<String, List<String>> _parse422(dynamic data) {
    if (data is! Map<String, dynamic>) return {};
    final violations = data['violations'];
    if (violations is! List) return {};
    final result = <String, List<String>>{};
    for (final v in violations) {
      if (v is! Map<String, dynamic>) continue;
      final field = v['propertyPath'] as String? ?? '';
      final message = v['message'] as String? ?? '';
      result.putIfAbsent(field, () => []).add(message);
    }
    return result;
  }
}
