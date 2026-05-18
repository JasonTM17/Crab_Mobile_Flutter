import 'package:equatable/equatable.dart';
import '../../data/models/auth_models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, otpSent, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final String? pendingPhone;
  final bool requiresPhoneVerification;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.pendingPhone,
    this.requiresPhoneVerification = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    String? pendingPhone,
    bool? requiresPhoneVerification,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      requiresPhoneVerification:
          requiresPhoneVerification ?? this.requiresPhoneVerification,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, error, pendingPhone, requiresPhoneVerification];
}
