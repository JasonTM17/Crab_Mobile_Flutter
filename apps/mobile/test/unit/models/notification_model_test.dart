import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final json = {
      'id': 'n1',
      'type': 'ride',
      'title': 'Ride completed',
      'body': 'Your ride has ended.',
      'isRead': false,
      'createdAt': '2026-05-20T10:15:00.000',
    };

    test('fromJson parses required fields', () {
      final n = NotificationModel.fromJson(json);
      expect(n.id, 'n1');
      expect(n.type, 'ride');
      expect(n.title, 'Ride completed');
      expect(n.body, 'Your ride has ended.');
      expect(n.isRead, false);
      expect(n.createdAt, DateTime(2026, 5, 20, 10, 15, 0));
    });

    test('fromJson handles null data', () {
      final n = NotificationModel.fromJson(json);
      expect(n.data, isNull);
    });

    test('fromJson parses data map', () {
      final withData = {
        ...json,
        'data': {'rideId': 'r1', 'action': 'rate'},
      };
      final n = NotificationModel.fromJson(withData);
      expect(n.data, isNotNull);
      expect(n.data!['rideId'], 'r1');
    });

    test('isRead true variant', () {
      final readJson = {...json, 'isRead': true};
      final n = NotificationModel.fromJson(readJson);
      expect(n.isRead, true);
    });

    test('different notification types', () {
      for (final type in ['ride', 'food', 'payment', 'promo', 'chat']) {
        final typed = {...json, 'type': type};
        final n = NotificationModel.fromJson(typed);
        expect(n.type, type);
      }
    });
  });
}
