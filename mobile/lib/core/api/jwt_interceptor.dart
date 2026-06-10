import 'package:dio/dio.dart';
import '../auth/auth_token_storage.dart';

class JwtInterceptor extends QueuedInterceptorsWrapper {
  JwtInterceptor({
    required this._authStorage,
    required this._refreshDio,
    required this._refreshPath,
    required this._onRefreshFailed,
  });

  final AuthTokenStorage _authStorage;

  // Separate bare Dio instance used only for the refresh call —
  // avoids triggering this interceptor recursively on a 401 refresh response.
  final Dio _refreshDio;
  final String _refreshPath;
  final void Function() _onRefreshFailed;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final refreshToken = await _authStorage.readRefreshToken();
      if (refreshToken == null) {
        await _authStorage.clearAll();
        _onRefreshFailed();
        return handler.next(err);
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data?['token'] as String?;
      final newRefreshToken = response.data?['refresh_token'] as String?;

      if (newAccessToken == null) {
        throw Exception('Missing token in refresh response');
      }

      _authStorage.setAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _authStorage.saveRefreshToken(newRefreshToken);
      }

      final retried = await _retry(err.requestOptions, newAccessToken);
      return handler.resolve(retried);
    } catch (_) {
      await _authStorage.clearAll();
      _onRefreshFailed();
      return handler.next(err);
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String accessToken,
  ) {
    options.headers['Authorization'] = 'Bearer $accessToken';
    return _refreshDio.fetch(options);
  }
}
