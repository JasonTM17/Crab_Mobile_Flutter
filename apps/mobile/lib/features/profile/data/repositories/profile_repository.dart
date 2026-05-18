import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_profile_model.dart';

@injectable
class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<UserProfileModel> getProfile() async {
    final response = await _dioClient.dio.get(ApiConstants.profile);
    return UserProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    final response = await _dioClient.dio.patch(
      ApiConstants.profile,
      data: data,
    );
    return UserProfileModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.dio.post(
      '/users/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> deleteAccount() async {
    await _dioClient.dio.delete('/users/me');
  }
}
