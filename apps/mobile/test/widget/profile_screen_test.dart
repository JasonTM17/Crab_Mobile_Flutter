import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crab_mobile/features/auth/data/models/auth_models.dart';
import 'package:crab_mobile/features/profile/presentation/screens/profile_screen.dart';
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
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen', () {
    testWidgets('shows profile info when authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'u1',
            email: 'test@crab.vn',
            phone: '+84901',
            firstName: 'Nguyen Van',
            lastName: 'A',
            role: 'customer',
            status: 'active',
            phoneVerified: true,
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Nguyen Van A'), findsAtLeast(1));
      expect(find.textContaining('test@crab.vn'), findsAtLeast(1));
    });

    testWidgets('shows default user info when user is null', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        const AuthState(
          status: AuthStatus.unauthenticated,
          user: null,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('renders logout button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'u1',
            email: 'test@crab.vn',
            phone: '+84901',
            firstName: 'Nguyen Van',
            lastName: 'A',
            role: 'customer',
            status: 'active',
            phoneVerified: true,
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final logoutBtn =
          find.textContaining(RegExp(r'[Ll]ogout|[Đđ]ăng [Xx]uất'));
      expect(logoutBtn, findsAtLeast(1));
    });

    testWidgets('tapping logout dispatches AuthLogoutRequested',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'u1',
            email: 'test@crab.vn',
            phone: '+84901',
            firstName: 'Nguyen Van',
            lastName: 'A',
            role: 'customer',
            status: 'active',
            phoneVerified: true,
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final logoutBtn =
          find.textContaining(RegExp(r'[Ll]ogout|[Đđ]ăng [Xx]uất'));
      expect(logoutBtn, findsAtLeast(1));
      await tester.tap(logoutBtn.first);
      await tester.pump();

      verify(() => mockAuthBloc.add(const AuthLogoutRequested())).called(1);
    });

    testWidgets('renders avatar area', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(
        AuthState(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: 'u1',
            email: 'test@crab.vn',
            phone: '+84901',
            firstName: 'Nguyen Van',
            lastName: 'A',
            role: 'customer',
            status: 'active',
            phoneVerified: true,
          ),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.byType(CircleAvatar).evaluate().isNotEmpty ||
            find.byIcon(Icons.person).evaluate().isNotEmpty,
        true,
      );
    });
  });
}
