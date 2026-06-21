import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/trash_card_model.dart';

part 'trash_repository.g.dart';

@Riverpod(keepAlive: true)
TrashRepository trashRepository(Ref ref) => TrashRepository(
      ref.watch(dioProvider),
      ref.watch(appDatabaseProvider),
    );

class TrashRepository {
  const TrashRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  static const _pageSize = 20;

  /// Fetches a page of soft-deleted cards from the server. Trash is never
  /// cached locally — restore/permanent-delete both require connectivity.
  Future<List<TrashCard>> getTrash(int offset) async {
    try {
      final page = (offset ~/ _pageSize) + 1;
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/cards/trash',
        queryParameters: {'page': page, 'itemsPerPage': _pageSize},
      );
      final members =
          (response.data?['member'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
      return members.map(_mapTrashCard).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Restores a card from trash. The server returns the full restored card,
  /// which we write back to the local `cards` table so it reappears in the
  /// main list without waiting for the next sync.
  Future<void> restore(String id) async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>('/api/cards/$id/restore');
      final data = response.data;
      if (data != null) {
        await _db.upsertCards([_toCompanion(data)]);
      }
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Permanently deletes a card already in trash (physical delete, 204).
  Future<void> permanentDelete(String id) async {
    try {
      await _dio.delete<void>('/api/cards/$id/permanent');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  TrashCard _mapTrashCard(Map<String, dynamic> json) => TrashCard(
        id: json['id'] as String,
        name: json['name'] as String,
        barcodeType: json['barcodeType'] as String,
        barcodeContent: json['barcodeContent'] as String,
        deletedAt: DateTime.parse(json['deletedAt'] as String),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
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
        updatedAt: Value(DateTime.parse(json['updatedAt'] as String)),
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
      case 404:
        return const NotFoundException();
      default:
        if (status != null && status >= 500) return const ServerException();
        if (status != null) {
          return ServerException('Unexpected response: ${e.message}');
        }
        return NetworkException(e.message ?? 'Unknown error');
    }
  }
}
