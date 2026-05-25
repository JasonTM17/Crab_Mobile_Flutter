import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/utils/error_message.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthEmailLoginRequested>(_onEmailLogin);
    on<AuthPhoneLoginRequested>(_onPhoneLogin);
    on<AuthOtpVerifyRequested>(_onOtpVerify);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthPasswordResetConfirmed>(_onPasswordResetConfirm);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isAuth = await _repository.storage.isAuthenticated();
      if (!isAuth) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }
      final user = await _repository.me();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onRegister(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final auth = await _repository.register(
        email: event.email,
        phone: event.phone,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        user: auth.user,
        pendingPhone: event.phone,
        requiresPhoneVerification: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.error, error: mapErrorToMessage(e)));
    }
  }

  Future<void> _onEmailLogin(
      AuthEmailLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final auth = await _repository.login(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: auth.user));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.error, error: mapErrorToMessage(e)));
    }
  }

  Future<void> _onPhoneLogin(
      AuthPhoneLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.requestPhoneLogin(event.phone);
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        pendingPhone: event.phone,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    }
  }

  Future<void> _onOtpVerify(
      AuthOtpVerifyRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final auth = await _repository.verifyPhoneLogin(event.phone, event.code);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: auth.user,
        pendingPhone: null,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    }
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.requestPasswordReset(event.phone);
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        pendingPhone: event.phone,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    }
  }

  Future<void> _onPasswordResetConfirm(
    AuthPasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.confirmPasswordReset(
        event.phone,
        event.code,
        event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingPhone: null,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: _extractError(e)));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is List) return msg.join(', ');
      return msg.toString();
    }
    return e.message ?? 'Network error';
  }
}
