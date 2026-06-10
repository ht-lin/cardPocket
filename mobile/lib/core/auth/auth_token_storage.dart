import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  AuthTokenStorage(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const _refreshKey = 'refresh_token';

  String? _accessToken;

  String? getAccessToken() => _accessToken;

  void setAccessToken(String token) => _accessToken = token;

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: _refreshKey, value: token);

  Future<String?> readRefreshToken() => _secureStorage.read(key: _refreshKey);

  Future<void> clearAll() async {
    _accessToken = null;
    await _secureStorage.delete(key: _refreshKey);
  }
}
