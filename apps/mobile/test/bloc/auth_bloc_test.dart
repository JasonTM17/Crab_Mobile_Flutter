import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockAuthRepository mockRepo;
  late MockAuthStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockAuthStorage();
    when(() => mockRepo.storage).thenReturn(mockStorage);
  });

  group('AuthBloc', () {
    test('initial state is AuthState with status initial', () {
      final bloc = AuthBloc(repository: mockRepo);
      expect(bloc.state, const AuthState());
      expect(bloc.state.status, AuthStatus.initial);
      bloc.close();
    });

    // ═════════════════════════════════════════════════════════
    // AuthCheckRequested
    // ═════════════════════════════════════════════════════════
    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when user is authenticated',
        build: () {
          when(() => mockStorage.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockRepo.me()).thenAnswer((_) async => tUserModel);
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: tUserModel),
        ],
        verify: (_) {
          verify(() => mockStorage.isAuthenticated()).called(1);
          verify(() => mockRepo.me()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when not authenticated',
        build: () {
          when(() => mockStorage.isAuthenticated())
              .thenAnswer((_) async => false);
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] on exception',
        build: () {
          when(() => mockStorage.isAuthenticated()).thenThrow(Exception());
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthEmailLoginRequested
    // ═════════════════════════════════════════════════════════
    group('AuthEmailLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on successful login',
        build: () {
          when(() => mockRepo.login(tEmail, tPassword))
              .thenAnswer((_) async => tAuthResponse);
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(
          const AuthEmailLoginRequested(email: tEmail, password: tPassword),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: tAuthResponse.user),
        ],
        verify: (_) {
          verify(() => mockRepo.login(tEmail, tPassword)).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on DioException',
        build: () {
          when(() => mockRepo.login(tEmail, tPassword)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: ''),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
                data: {'message': 'Invalid credentials'},
              ),
            ),
          );
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(
          const AuthEmailLoginRequested(email: tEmail, password: tPassword),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error)
              .having((s) => s.error, 'error', 'Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] with list message',
        build: () {
          when(() => mockRepo.login(tEmail, tPassword)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: ''),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 400,
                data: {
                  'message': ['email is invalid', 'password too short']
                },
              ),
            ),
          );
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(
          const AuthEmailLoginRequested(email: tEmail, password: tPassword),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error)
              .having((s) => s.error, 'error',
                  'email is invalid, password too short'),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthPhoneLoginRequested
    // ═════════════════════════════════════════════════════════
    group('AuthPhoneLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, otpSent] on success',
        build: () {
          when(() => mockRepo.requestPhoneLogin(tPhone))
              .thenAnswer((_) async {});
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthPhoneLoginRequested(phone: tPhone)),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.otpSent, pendingPhone: tPhone),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthOtpVerifyRequested
    // ═════════════════════════════════════════════════════════
    group('AuthOtpVerifyRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on successful OTP verify',
        build: () {
          when(() => mockRepo.verifyPhoneLogin(tPhone, tOtpCode))
              .thenAnswer((_) async => tAuthResponse);
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(
          const AuthOtpVerifyRequested(phone: tPhone, code: tOtpCode),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(
            status: AuthStatus.authenticated,
            user: tAuthResponse.user,
          ),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthRegisterRequested
    // ═════════════════════════════════════════════════════════
    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, otpSent] with requiresPhoneVerification',
        build: () {
          when(() => mockRepo.register(
                email: tEmail,
                phone: tPhone,
                password: tPassword,
                firstName: tFirstName,
                lastName: tLastName,
              )).thenAnswer((_) async => tAuthResponse);
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          email: tEmail,
          phone: tPhone,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(
            status: AuthStatus.otpSent,
            user: tAuthResponse.user,
            pendingPhone: tPhone,
            requiresPhoneVerification: true,
          ),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthLogoutRequested
    // ═════════════════════════════════════════════════════════
    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] and calls repository.logout',
        build: () {
          when(() => mockRepo.logout()).thenAnswer((_) async {});
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockRepo.logout()).called(1);
        },
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthPasswordResetRequested
    // ═════════════════════════════════════════════════════════
    group('AuthPasswordResetRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, otpSent] on success',
        build: () {
          when(() => mockRepo.requestPasswordReset(tPhone))
              .thenAnswer((_) async {});
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) =>
            bloc.add(const AuthPasswordResetRequested(phone: tPhone)),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.otpSent, pendingPhone: tPhone),
        ],
      );
    });

    // ═════════════════════════════════════════════════════════
    // AuthPasswordResetConfirmed
    // ═════════════════════════════════════════════════════════
    group('AuthPasswordResetConfirmed', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] on success',
        build: () {
          when(() => mockRepo.confirmPasswordReset(
                tPhone,
                tOtpCode,
                'NewPass@1',
              )).thenAnswer((_) async {});
          return AuthBloc(repository: mockRepo);
        },
        act: (bloc) => bloc.add(const AuthPasswordResetConfirmed(
          phone: tPhone,
          code: tOtpCode,
          newPassword: 'NewPass@1',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });
  });
}
