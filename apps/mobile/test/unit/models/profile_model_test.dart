import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/profile/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel', () {
    final json = {
      'id': 'u1',
      'email': 'test@crab.vn',
      'fullName': 'Nguyen Van A',
      'phone': '+84901234567',
      'role': 'customer',
      'isVerified': true,
      'createdAt': '2026-01-01T00:00:00.000',
    };

    test('fromJson parses all fields', () {
      final p = UserProfileModel.fromJson(json);
      expect(p.id, 'u1');
      expect(p.email, 'test@crab.vn');
      expect(p.fullName, 'Nguyen Van A');
      expect(p.phone, '+84901234567');
      expect(p.role, 'customer');
      expect(p.isVerified, true);
      expect(p.createdAt, DateTime(2026, 1, 1));
    });

    test('fromJson handles null optionals', () {
      final minimal = {
        'id': 'u2',
        'email': 'b@b.com',
        'role': 'driver',
        'isVerified': false,
        'createdAt': '2026-06-01T00:00:00.000',
      };
      final p = UserProfileModel.fromJson(minimal);
      expect(p.fullName, isNull);
      expect(p.phone, isNull);
      expect(p.avatarUrl, isNull);
    });

    test('fromJson parses avatarUrl', () {
      final withAvatar = {...json, 'avatarUrl': 'https://img.com/a.png'};
      final p = UserProfileModel.fromJson(withAvatar);
      expect(p.avatarUrl, 'https://img.com/a.png');
    });

    test('driver role', () {
      final driver = {...json, 'role': 'driver'};
      final p = UserProfileModel.fromJson(driver);
      expect(p.role, 'driver');
    });

    test('unverified profile', () {
      final unverified = {...json, 'isVerified': false};
      final p = UserProfileModel.fromJson(unverified);
      expect(p.isVerified, false);
    });
  });
}
