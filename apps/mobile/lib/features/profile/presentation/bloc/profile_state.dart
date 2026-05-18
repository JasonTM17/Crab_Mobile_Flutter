import '../../data/models/user_profile_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  const ProfileLoaded({required this.profile});
}

class ProfileUpdated extends ProfileState {
  final UserProfileModel profile;
  const ProfileUpdated({required this.profile});
}

class PasswordChanged extends ProfileState {
  const PasswordChanged();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
}

class LoggedOut extends ProfileState {
  const LoggedOut();
}
