abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? fullName;
  final String? phone;
  const UpdateProfile({this.fullName, this.phone});
}

class ChangePassword extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });
}

class LogoutRequested extends ProfileEvent {
  const LogoutRequested();
}
