import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import '../models/token_pair.dart';

class SecureTokenStorage implements TokenStorage<TokenPair> {
  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> delete() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<TokenPair?> read() async {
    final access = await _storage.read(key: _accessTokenKey);
    final refresh = await _storage.read(key: _refreshTokenKey);

    if (access != null && refresh != null) {
      return TokenPair(
        accessToken: access,
        refreshToken: refresh,

        access: access,
        refresh: refresh,
      );
    }
    return null;
  }

  @override
  Future<void> write(TokenPair token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }
}
