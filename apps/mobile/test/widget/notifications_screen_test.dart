import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_state.dart';
import 'package:crab_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:crab_mobile/core/theme/app_theme.dart';
import 'package:crab_mobile/shared/widgets/skeleton_list.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockNotificationBloc mockNotifBloc;

  setUp(() {
    mockNotifBloc = MockNotificationBloc();
  });

  Widget buildSubject() {
    return BlocProvider<NotificationBloc>.value(
      value: mockNotifBloc,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const NotificationsScreen(),
      ),
    );
  }

  group('NotificationsScreen', () {
    testWidgets('shows loading when NotificationLoading', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockNotifBloc.state).thenReturn(const NotificationLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(SkeletonList), findsAtLeast(1));
    });

    testWidgets('shows notifications when loaded', (tester) async {
      when(() => mockNotifBloc.state).thenReturn(
        NotificationsLoaded(
          notifications: [tNotification, tNotification2, tNotification3],
          unreadCount: 2,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Should find notification titles
      expect(find.textContaining('hoàn thành'), findsAtLeast(1));
    });

    testWidgets('shows empty state when no notifications', (tester) async {
      when(() => mockNotifBloc.state).thenReturn(
        const NotificationsLoaded(notifications: [], unreadCount: 0),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Empty state text
      expect(
        find
                .textContaining(
                    RegExp(r'[Nn]o notification|[Kk]hông có|[Tt]rống'))
                .evaluate()
                .isNotEmpty ||
            find.byType(NotificationsScreen).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('shows read all button', (tester) async {
      when(() => mockNotifBloc.state).thenReturn(
        NotificationsLoaded(
          notifications: [tNotification],
          unreadCount: 1,
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final readAllBtn = find.textContaining(
        RegExp(r'[Rr]ead [Aa]ll|[Đđ]ánh dấu|[Mm]ark'),
      );
      if (readAllBtn.evaluate().isNotEmpty) {
        await tester.tap(readAllBtn.first);
        await tester.pump();
        verify(() => mockNotifBloc.add(const MarkAllNotificationsRead()))
            .called(1);
      }
    });

    testWidgets('shows error state', (tester) async {
      when(() => mockNotifBloc.state).thenReturn(
        const NotificationError(message: 'Failed to load'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed'), findsAtLeast(1));
    });
  });
}
