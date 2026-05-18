import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  final String firstName;
  final String lastName;

  const AuthRegisterRequested({
    required this.email,
    required this.phone,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, phone, password, firstName, lastName];
}

class AuthEmailLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthPhoneLoginRequested extends AuthEvent {
  final String phone;
  const AuthPhoneLoginRequested({required this.phone});
  @override
  List<Object?> get props => [phone];
}

class AuthOtpVerifyRequested extends AuthEvent {
  final String phone;
  final String code;
  const AuthOtpVerifyRequested({required this.phone, required this.code});
  @override
  List<Object?> get props => [phone, code];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String phone;
  const AuthPasswordResetRequested({required this.phone});
  @override
  List<Object?> get props => [phone];
}

class AuthPasswordResetConfirmed extends AuthEvent {
  final String phone;
  final String code;
  final String newPassword;
  const AuthPasswordResetConfirmed({
    required this.phone,
    required this.code,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [phone, code, newPassword];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
