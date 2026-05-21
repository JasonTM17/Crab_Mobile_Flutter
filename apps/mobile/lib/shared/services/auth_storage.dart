import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/storage_keys.dart';

class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage(this._storage);

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);
  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);
  Future<String?> getUserId() => _storage.read(key: StorageKeys.userId);
  Future<String?> getUserRole() => _storage.read(key: StorageKeys.userRole);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<void> saveUser({
    required String userId,
    required String role,
  }) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
    await _storage.write(key: StorageKeys.userRole, value: role);
  }

  Future<void> clear() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userRole);
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
