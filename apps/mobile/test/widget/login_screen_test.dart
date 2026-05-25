import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crab_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:crab_mobile/shared/widgets/gradient_button.dart';
import 'package:crab_mobile/core/theme/app_theme.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildSubject() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap on Email toggle first to show email/password fields
      final emailToggle = find.text('Email');
      if (emailToggle.evaluate().isNotEmpty) {
        await tester.tap(emailToggle);
        await tester.pumpAndSettle();
      }

      expect(find.byType(TextField), findsAtLeast(2));
    });

    testWidgets('renders login button', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Look for custom GradientButton widget
      final loginBtn = find.byType(GradientButton);
      expect(loginBtn, findsAtLeast(1));
    });

    testWidgets('shows loading when AuthStatus.loading', (tester) async {
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthState(status: AuthStatus.loading));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('renders register link', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Should find register/sign up text
      final registerText = find
          .textContaining(RegExp(r'[Rr]egister|[Ss]ign [Uu]p|[Dd]ăng [Kk]ý'));
      expect(registerText, findsAtLeast(1));
    });

    testWidgets('initial state shows form correctly', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthState());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
