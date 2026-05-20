import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../../../core/network/socket_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/utils/error_message.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  final SocketClient _socketClient;
  io.Socket? _notifSocket;

  NotificationBloc(this._notificationRepository, this._socketClient)
      : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _connectSocket() async {
    _notifSocket ??=
        await _socketClient.connect(ApiConstants.notificationNamespace);
    _notifSocket!.on('notification', (data) {
      add(NotificationReceived(data: data as Map<String, dynamic>));
    });
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      await _connectSocket();
      final notifications = await _notificationRepository.getNotifications(
        page: event.page,
      );
      final unreadCount = await _notificationRepository.getUnreadCount();
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationRepository.markAsRead(event.notificationId);
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updated = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      emit(currentState.copyWith(
        notifications: updated,
        unreadCount: (currentState.unreadCount - 1).clamp(0, 999),
      ));
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationRepository.markAllAsRead();
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updated = currentState.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      emit(currentState.copyWith(notifications: updated, unreadCount: 0));
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final notification = NotificationModel.fromJson(event.data);
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      emit(currentState.copyWith(
        notifications: [notification, ...currentState.notifications],
        unreadCount: currentState.unreadCount + 1,
      ));
    }
  }

  @override
  Future<void> close() {
    _notifSocket?.dispose();
    return super.close();
  }
}
