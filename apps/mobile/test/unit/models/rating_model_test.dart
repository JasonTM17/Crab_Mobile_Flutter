import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/rating/data/models/rating_model.dart';

void main() {
  group('RatingModel', () {
    final json = {
      'id': 'r1',
      'targetType': 'ride',
      'targetId': 'ride-001',
      'score': 5,
      'comment': 'Excellent driver',
      'tags': ['polite', 'safe_driving'],
      'imageUrls': ['https://img.com/a.jpg'],
      'userId': 'u1',
      'userName': 'Nguyen Van A',
      'createdAt': '2026-05-20T10:20:00.000',
    };

    test('fromJson parses all fields', () {
      final r = RatingModel.fromJson(json);
      expect(r.id, 'r1');
      expect(r.targetType, 'ride');
      expect(r.targetId, 'ride-001');
      expect(r.score, 5);
      expect(r.comment, 'Excellent driver');
      expect(r.tags, ['polite', 'safe_driving']);
      expect(r.imageUrls, ['https://img.com/a.jpg']);
      expect(r.userId, 'u1');
      expect(r.userName, 'Nguyen Van A');
      expect(r.createdAt, DateTime(2026, 5, 20, 10, 20, 0));
    });

    test('fromJson handles null optionals', () {
      final minimal = {
        'id': 'r2',
        'targetType': 'food',
        'targetId': 'order-001',
        'score': 3,
        'tags': <String>[],
        'imageUrls': <String>[],
        'userId': 'u2',
        'createdAt': '2026-05-20T00:00:00.000',
      };
      final r = RatingModel.fromJson(minimal);
      expect(r.comment, isNull);
      expect(r.replyContent, isNull);
      expect(r.replyAt, isNull);
      expect(r.userName, isNull);
      expect(r.userAvatar, isNull);
    });

    test('fromJson parses reply fields', () {
      final withReply = {
        ...json,
        'replyContent': 'Thank you!',
        'replyAt': '2026-05-21T08:00:00.000',
      };
      final r = RatingModel.fromJson(withReply);
      expect(r.replyContent, 'Thank you!');
      expect(r.replyAt, DateTime(2026, 5, 21, 8, 0, 0));
    });

    test('score range validation', () {
      for (final score in [1, 2, 3, 4, 5]) {
        final j = {...json, 'score': score};
        final r = RatingModel.fromJson(j);
        expect(r.score, score);
      }
    });
  });

  group('RatingStatsModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'average': 4.7,
        'count': 1250,
        'distribution': {'5': 800, '4': 300, '3': 100, '2': 30, '1': 20},
      };
      final s = RatingStatsModel.fromJson(json);
      expect(s.average, 4.7);
      expect(s.count, 1250);
      expect(s.distribution[5], 800);
      expect(s.distribution[1], 20);
    });

    test('fromJson handles zero stats', () {
      final json = {
        'average': 0.0,
        'count': 0,
        'distribution': <String, int>{},
      };
      final s = RatingStatsModel.fromJson(json);
      expect(s.average, 0.0);
      expect(s.count, 0);
      expect(s.distribution, isEmpty);
    });
  });
}
