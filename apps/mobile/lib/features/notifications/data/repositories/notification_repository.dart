import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

@injectable
class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _dioClient.dio.patch('/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dioClient.dio.patch('/notifications/read-all');
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.dio.get('/notifications/unread-count');
    return (response.data['data'] as num?)?.toInt() ?? 0;
  }
}
