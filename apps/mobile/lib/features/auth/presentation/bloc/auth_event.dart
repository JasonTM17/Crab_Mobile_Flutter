import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class LoginRequested extends AuthEvent {
  final String emailOrPhone;
  final String password;

  const LoginRequested({
    required this.emailOrPhone,
    required this.password,
  });

  @override
  List<Object?> get props => [emailOrPhone, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
