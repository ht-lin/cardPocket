import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/api_exception.dart';
import '../domain/auth_models.dart';
import 'auth_dio_provider.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(authDioProvider));
}

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthTokens> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthTokens.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<User> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: request.toJson(),
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return AuthTokens.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/api/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> resendVerification(String email) async {
    try {
      await _dio.post<void>(
        '/api/auth/resend-verification',
        data: {'email': email},
      );
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
        final errors = _parse422(e.response?.data);
        return UnprocessableException(errors);
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
