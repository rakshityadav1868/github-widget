import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely stores the GitHub access token and the signed-in username using
/// the platform keystore/keychain.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'github_access_token';
  static const _loginKey = 'github_login';

  Future<void> save({required String token, required String login}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _loginKey, value: login);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readLogin() => _storage.read(key: _loginKey);

  Future<bool> get hasToken async => (await readToken()) != null;

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _loginKey);
  }
}
