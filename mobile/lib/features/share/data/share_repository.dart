import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/card_share_model.dart';

part 'share_repository.g.dart';

@Riverpod(keepAlive: true)
ShareRepository shareRepository(Ref ref) => ShareRepository(
      ref.watch(dioProvider),
      ref.watch(appDatabaseProvider),
    );

class ShareRepository {
  const ShareRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  Future<List<CardShareModel>> getShares(String cardId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/cards/$cardId/shares');
      final list = (response.data ?? []).cast<Map<String, dynamic>>();
      return list.map(_mapShare).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> addViewer(String cardId, String viewerId) async {
    try {
      await _dio.post<void>(
        '/api/cards/$cardId/shares',
        data: {'viewerId': viewerId},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> removeViewer(String shareId) async {
    try {
      await _dio.delete<void>('/api/card-shares/$shareId');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> leave(String shareId, String cardId) async {
    try {
      await _dio.delete<void>('/api/card-shares/$shareId');
      await _db.deleteCardsByIds([cardId]);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> setNickname(
    String shareId,
    String cardId,
    String? nickname,
  ) async {
    try {
      await _dio.patch<void>(
        '/api/card-shares/$shareId',
        data: {'viewerNickname': nickname},
      );
      await _db.updateViewerNickname(cardId, nickname);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  CardShareModel _mapShare(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>;
    return CardShareModel(
      id: json['id'] as String,
      viewerUserId: viewer['id'] as String,
      viewerUserName: viewer['userName'] as String,
      viewerNickname: json['viewerNickname'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

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
        final data = e.response?.data;
        if (data is! Map<String, dynamic>) return const UnprocessableException({});
        final violations = data['violations'];
        if (violations is! List) return const UnprocessableException({});
        final errors = <String, List<String>>{};
        for (final v in violations) {
          if (v is! Map<String, dynamic>) continue;
          final field = v['propertyPath'] as String? ?? '';
          final message = v['message'] as String? ?? '';
          errors.putIfAbsent(field, () => []).add(message);
        }
        return UnprocessableException(errors);
      default:
        if (status != null && status >= 500) return const ServerException();
        return NetworkException(e.message ?? 'Unknown error');
    }
  }
}
