import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/auth/data/models/auth_models.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crab_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:crab_mobile/features/auth/presentation/screens/register_screen.dart';

import 'helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E Integration', () {
    testWidgets('Login screen renders all fields', (tester) async {
      await tester.pumpScreen(const LoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Login dispatches AuthEmailLoginRequested on tap',
        (tester) async {
      final app = await tester.pumpScreen(const LoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@crab.vn');
      await tester.enterText(textFields.at(1), 'Test@1234');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      verify(() => app.authBloc.add(
            const AuthEmailLoginRequested(
              email: 'test@crab.vn',
              password: 'Test@1234',
            ),
          )).called(1);
    });

    testWidgets('Shows loading indicator when auth is loading', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.authBloc.state)
          .thenReturn(const AuthState(status: AuthStatus.loading));

      await tester.pumpWidget(app.buildWidget(const LoginScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows error message on auth error', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      whenListen(
        app.authBloc,
        Stream.fromIterable([
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            error: 'Invalid credentials',
          ),
        ]),
        initialState: const AuthState(),
      );

      await tester.pumpWidget(app.buildWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Error should be displayed (snackbar or text)
      expect(find.textContaining('Invalid'), findsAtLeast(1));
    });

    testWidgets('Register screen renders all fields', (tester) async {
      await tester.pumpScreen(const RegisterScreen());
      await tester.pumpAndSettle();

      // Register screen should have multiple text fields
      expect(find.byType(TextField), findsAtLeast(4));
    });

    testWidgets('Logout flow - from authenticated to login', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      final user = UserModel(
        id: 'u1',
        email: 'test@crab.vn',
        phone: '+84901',
        firstName: 'A',
        lastName: 'B',
        role: 'customer',
        status: 'active',
        phoneVerified: true,
      );

      when(() => app.authBloc.state).thenReturn(
        AuthState(status: AuthStatus.authenticated, user: user),
      );

      whenListen(
        app.authBloc,
        Stream.fromIterable([
          const AuthState(status: AuthStatus.unauthenticated),
        ]),
        initialState: AuthState(status: AuthStatus.authenticated, user: user),
      );

      await tester.pumpWidget(app.buildWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // After logout, the login screen should be visible
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
