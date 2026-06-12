import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_provider.dart';
import '../../auth/domain/auth_models.dart';

part 'user_repository.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) =>
    UserRepository(ref.watch(dioProvider));

class UserRepository {
  const UserRepository(this._dio);

  final Dio _dio;

  Future<User> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/users/me');
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<User> updateUsername(String userName) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/users/me',
        data: {'userName': userName},
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<User> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/users/me',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete<void>('/api/users/me');
    } on DioException catch (e) {
      throw _mapError(e);
    }
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
