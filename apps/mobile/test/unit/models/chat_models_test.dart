import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/chat/data/models/conversation_model.dart';

void main() {
  group('ParticipantModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'userId': 'u1',
        'name': 'Nguyen Van A',
        'avatarUrl': 'https://img.com/a.png',
        'role': 'customer',
      };
      final p = ParticipantModel.fromJson(json);
      expect(p.userId, 'u1');
      expect(p.name, 'Nguyen Van A');
      expect(p.avatarUrl, 'https://img.com/a.png');
      expect(p.role, 'customer');
    });

    test('fromJson handles null avatarUrl', () {
      final json = {'userId': 'u2', 'name': 'B', 'role': 'driver'};
      final p = ParticipantModel.fromJson(json);
      expect(p.avatarUrl, isNull);
    });
  });

  group('ConversationModel', () {
    final json = {
      'id': 'c1',
      'type': 'ride',
      'rideId': 'ride-001',
      'participants': [
        {'userId': 'u1', 'name': 'A', 'role': 'customer'},
        {'userId': 'u2', 'name': 'B', 'role': 'driver'},
      ],
      'lastMessage': {
        'id': 'm1',
        'conversationId': 'c1',
        'senderId': 'u2',
        'content': 'Hello',
        'type': 'text',
        'isRead': false,
        'createdAt': '2026-05-20T10:05:00.000',
      },
      'unreadCount': 2,
      'createdAt': '2026-05-20T10:00:00.000',
      'updatedAt': '2026-05-20T10:05:00.000',
    };

    test('fromJson parses all fields', () {
      final c = ConversationModel.fromJson(json);
      expect(c.id, 'c1');
      expect(c.type, 'ride');
      expect(c.rideId, 'ride-001');
      expect(c.participants.length, 2);
      expect(c.lastMessage?.content, 'Hello');
      expect(c.unreadCount, 2);
    });

    test('fromJson handles null optionals', () {
      final minimal = {
        'id': 'c2',
        'type': 'food',
        'participants': <Map<String, dynamic>>[],
        'unreadCount': 0,
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };
      final c = ConversationModel.fromJson(minimal);
      expect(c.rideId, isNull);
      expect(c.orderId, isNull);
      expect(c.lastMessage, isNull);
    });

    test('fromJson parses orderId', () {
      final withOrder = {
        ...json,
        'type': 'food',
        'orderId': 'order-001',
      };
      final c = ConversationModel.fromJson(withOrder);
      expect(c.orderId, 'order-001');
    });
  });

  group('MessageModel', () {
    final json = {
      'id': 'm1',
      'conversationId': 'c1',
      'senderId': 'u2',
      'content': 'Toi dang den',
      'type': 'text',
      'isRead': false,
      'createdAt': '2026-05-20T10:05:00.000',
    };

    test('fromJson parses all fields', () {
      final m = MessageModel.fromJson(json);
      expect(m.id, 'm1');
      expect(m.conversationId, 'c1');
      expect(m.senderId, 'u2');
      expect(m.content, 'Toi dang den');
      expect(m.type, 'text');
      expect(m.isRead, false);
      expect(m.createdAt, DateTime(2026, 5, 20, 10, 5, 0));
    });

    test('fromJson handles null metadata', () {
      final m = MessageModel.fromJson(json);
      expect(m.metadata, isNull);
    });

    test('fromJson parses metadata', () {
      final withMeta = {
        ...json,
        'metadata': {'imageUrl': 'https://img.com/a.jpg'},
      };
      final m = MessageModel.fromJson(withMeta);
      expect(m.metadata, isNotNull);
      expect(m.metadata!['imageUrl'], 'https://img.com/a.jpg');
    });

    test('read message', () {
      final read = {...json, 'isRead': true};
      final m = MessageModel.fromJson(read);
      expect(m.isRead, true);
    });
  });
}
