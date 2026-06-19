import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_provider.dart';
import '../domain/friend_model.dart';

part 'friendship_repository.g.dart';

@Riverpod(keepAlive: true)
FriendshipRepository friendshipRepository(Ref ref) =>
    FriendshipRepository(ref.watch(dioProvider));

class FriendshipRepository {
  const FriendshipRepository(this._dio);

  final Dio _dio;

  Future<List<Friendship>> getFriends() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/friendships');
      return _members(response.data).map(_mapFriendship).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<FriendRequest>> getPendingRequests() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/api/friendships/requests');
      return _members(response.data).map(_mapFriendRequest).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> sendRequest(String addresseeId) async {
    try {
      await _dio.post<void>(
        '/api/friendships',
        data: {'addresseeId': addresseeId},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> acceptRequest(String id) async {
    try {
      await _dio.patch<void>('/api/friendships/$id/accept');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteOrReject(String id) async {
    try {
      await _dio.delete<void>('/api/friendships/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<UserSummary>> searchUsers(String q) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/users/search',
        queryParameters: {'q': q},
      );
      return _members(response.data).map(_mapUserSummary).toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // API Platform serves collections as a Hydra envelope under
  // application/ld+json: the items live under `member`.
  List<Map<String, dynamic>> _members(Map<String, dynamic>? data) =>
      (data?['member'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

  Friendship _mapFriendship(Map<String, dynamic> json) => Friendship(
        id: json['id'] as String,
        friend: _mapUserSummary(json['friend'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  FriendRequest _mapFriendRequest(Map<String, dynamic> json) => FriendRequest(
        id: json['id'] as String,
        requester:
            _mapUserSummary(json['requester'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  UserSummary _mapUserSummary(Map<String, dynamic> json) => UserSummary(
        id: json['id'] as String,
        userName: json['userName'] as String,
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
        return UnprocessableException(_parse422(e.response?.data));
      default:
        if (status != null && status >= 500) return const ServerException();
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
