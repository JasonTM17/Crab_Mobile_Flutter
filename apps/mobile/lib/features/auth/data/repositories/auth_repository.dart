import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

@singleton
class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dioClient)
      : _storage = const FlutterSecureStorage();

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.login,
      data: {
        'emailOrPhone': emailOrPhone,
        'password': password,
      },
    );

    await _saveTokens(response.data);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    await _saveTokens(response.data);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> refreshToken() async {
    final token = await _storage.read(key: ApiConstants.refreshTokenKey);
    if (token == null) throw Exception('No refresh token');

    final response = await _dioClient.dio.post(
      ApiConstants.refreshToken,
      data: {'refreshToken': token},
    );

    await _saveTokens(response.data);
    return UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logout);
    } on DioException catch (_) {
      // Ignore errors on logout
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: ApiConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken != null) {
      await _storage.write(
        key: ApiConstants.accessTokenKey,
        value: accessToken,
      );
    }
    if (refreshToken != null) {
      await _storage.write(
        key: ApiConstants.refreshTokenKey,
        value: refreshToken,
      );
    }
  }
}
