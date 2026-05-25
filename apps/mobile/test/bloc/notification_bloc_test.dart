import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:crab_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

class MockSocket extends Mock implements io.Socket {}

void main() {
  late MockNotificationRepository mockRepo;
  late MockSocketClient mockSocketClient;
  late MockSocket mockSocket;

  setUp(() {
    mockRepo = MockNotificationRepository();
    mockSocketClient = MockSocketClient();
    mockSocket = MockSocket();

    // Mock socket connections
    when(() => mockSocketClient.connect(any()))
        .thenAnswer((_) async => mockSocket);
    when(() => mockSocket.on(any(), any())).thenReturn(() {});
    when(() => mockSocket.emit(any(), any())).thenAnswer((_) => mockSocket);
  });

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      final bloc = NotificationBloc(mockRepo, mockSocketClient);
      expect(bloc.state, isA<NotificationInitial>());
      bloc.close();
    });

    group('LoadNotifications', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationsLoaded] on success',
        build: () {
          when(() => mockRepo.getNotifications(page: 1)).thenAnswer(
              (_) async => [tNotification, tNotification2, tNotification3]);
          when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => 2);
          return NotificationBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          isA<NotificationLoading>(),
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.length, 'count', 3)
              .having((s) => s.unreadCount, 'unread', 2),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits [NotificationLoading, NotificationError] on failure',
        build: () {
          when(() => mockRepo.getNotifications(page: 1))
              .thenThrow(Exception('Network error'));
          return NotificationBloc(mockRepo, mockSocketClient);
        },
        act: (bloc) => bloc.add(const LoadNotifications()),
        expect: () => [
          isA<NotificationLoading>(),
          isA<NotificationError>(),
        ],
      );
    });

    group('MarkNotificationRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks individual notification as read',
        build: () {
          when(() => mockRepo.markAsRead('notif-uuid-001'))
              .thenAnswer((_) async {});
          return NotificationBloc(mockRepo, mockSocketClient);
        },
        seed: () => NotificationsLoaded(
          notifications: [tNotification, tNotification2],
          unreadCount: 1,
        ),
        act: (bloc) => bloc.add(
          const MarkNotificationRead(notificationId: 'notif-uuid-001'),
        ),
        expect: () => [
          isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unread', 0),
        ],
        verify: (_) {
          verify(() => mockRepo.markAsRead('notif-uuid-001')).called(1);
        },
      );
    });

    group('MarkAllNotificationsRead', () {
      blocTest<NotificationBloc, NotificationState>(
        'marks all notifications as read',
        build: () {
          when(() => mockRepo.markAllAsRead()).thenAnswer((_) async {});
          return NotificationBloc(mockRepo, mockSocketClient);
        },
        seed: () => NotificationsLoaded(
          notifications: [tNotification, tNotification2, tNotification3],
          unreadCount: 2,
        ),
        act: (bloc) => bloc.add(const MarkAllNotificationsRead()),
        expect: () => [
          isA<NotificationsLoaded>().having((s) => s.unreadCount, 'unread', 0),
        ],
        verify: (_) {
          verify(() => mockRepo.markAllAsRead()).called(1);
        },
      );
    });

    group('NotificationReceived', () {
      blocTest<NotificationBloc, NotificationState>(
        'adds new notification to the list',
        build: () => NotificationBloc(mockRepo, mockSocketClient),
        seed: () => NotificationsLoaded(
          notifications: [tNotification2],
          unreadCount: 0,
        ),
        act: (bloc) => bloc.add(const NotificationReceived(data: {
          'id': 'notif-uuid-new',
          'type': 'payment',
          'title': 'Payment received',
          'body': '200k VND deposited',
          'isRead': false,
          'createdAt': '2026-05-20T15:00:00.000',
        })),
        expect: () => [
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.length, 'count', 2)
              .having((s) => s.unreadCount, 'unread', 1),
        ],
      );
    });
  });
}
