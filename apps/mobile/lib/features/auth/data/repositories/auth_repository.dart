import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/auth_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final Dio dio;
  final AuthStorage storage;

  AuthRepository({required this.dio, required this.storage});

  Future<AuthResponse> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await dio.post(ApiConstants.authRegister, data: {
      'email': email,
      'phone': phone,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _persistAuth(auth);
    return auth;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await dio.post(ApiConstants.authLogin, data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _persistAuth(auth);
    return auth;
  }

  Future<void> requestPhoneLogin(String phone) async {
    await dio.post(ApiConstants.authPhoneLogin, data: {'phone': phone});
  }

  Future<AuthResponse> verifyPhoneLogin(String phone, String code) async {
    final response = await dio.post(
      ApiConstants.authPhoneVerify,
      data: {'phone': phone, 'code': code},
    );
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _persistAuth(auth);
    return auth;
  }

  Future<void> verifyPhone(String phone, String code) async {
    await dio.post(
      ApiConstants.authVerifyPhone,
      data: {'phone': phone, 'code': code},
    );
  }

  Future<void> requestPasswordReset(String phone) async {
    await dio.post(
      ApiConstants.authPasswordResetRequest,
      data: {'phone': phone},
    );
  }

  Future<void> confirmPasswordReset(
    String phone,
    String code,
    String newPassword,
  ) async {
    await dio.post(
      ApiConstants.authPasswordResetConfirm,
      data: {'phone': phone, 'code': code, 'newPassword': newPassword},
    );
  }

  Future<void> logout() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await dio.post(
          ApiConstants.authLogout,
          data: {'refresh_token': refreshToken},
        );
      } catch (_) {}
    }
    await storage.clear();
  }

  Future<UserModel> me() async {
    final response = await dio.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> _persistAuth(AuthResponse auth) async {
    await storage.saveTokens(
      accessToken: auth.tokens.accessToken,
      refreshToken: auth.tokens.refreshToken,
    );
    await storage.saveUser(userId: auth.user.id, role: auth.user.role);
  }
}
