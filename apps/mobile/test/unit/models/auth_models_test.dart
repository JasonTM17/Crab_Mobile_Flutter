import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthTokens', () {
    test('creates from constructor', () {
      final tokens = AuthTokens(
        accessToken: 'abc',
        refreshToken: 'xyz',
      );
      expect(tokens.accessToken, 'abc');
      expect(tokens.refreshToken, 'xyz');
    });

    test('fromJson parses correctly', () {
      final json = {'access_token': 'tk_a', 'refresh_token': 'tk_r'};
      final tokens = AuthTokens.fromJson(json);
      expect(tokens.accessToken, 'tk_a');
      expect(tokens.refreshToken, 'tk_r');
    });

    test('supports field comparison', () {
      final a = AuthTokens(accessToken: 'a', refreshToken: 'b');
      expect(a.accessToken, 'a');
      expect(a.refreshToken, 'b');
    });
  });

  group('UserModel', () {
    final json = {
      'id': 'u1',
      'email': 'a@b.com',
      'phone': '+84901',
      'firstName': 'First',
      'lastName': 'Last',
      'role': 'customer',
      'status': 'active',
      'phoneVerified': true,
    };

    test('fromJson parses all fields', () {
      final user = UserModel.fromJson(json);
      expect(user.id, 'u1');
      expect(user.email, 'a@b.com');
      expect(user.phone, '+84901');
      expect(user.firstName, 'First');
      expect(user.lastName, 'Last');
      expect(user.role, 'customer');
      expect(user.status, 'active');
      expect(user.phoneVerified, true);
    });

    test('fromJson handles null avatarUrl', () {
      final user = UserModel.fromJson(json);
      expect(user.avatarUrl, isNull);
    });

    test('fromJson parses avatarUrl when present', () {
      final withAvatar = {...json, 'avatarUrl': 'https://img.com/a.png'};
      final user = UserModel.fromJson(withAvatar);
      expect(user.avatarUrl, 'https://img.com/a.png');
    });

    test('fromJson defaults phoneVerified to false', () {
      final noVerified = Map<String, dynamic>.from(json)
        ..remove('phoneVerified');
      final user = UserModel.fromJson(noVerified);
      expect(user.phoneVerified, false);
    });

    test('compares fields', () {
      final a = UserModel.fromJson(json);
      expect(a.id, 'u1');
      expect(a.email, 'a@b.com');
    });
  });

  group('AuthResponse', () {
    final json = {
      'user': {
        'id': 'u1',
        'email': 'a@b.com',
        'phone': '+84901',
        'firstName': 'F',
        'lastName': 'L',
        'role': 'customer',
        'status': 'active',
        'phoneVerified': true,
      },
      'tokens': {
        'access_token': 'at',
        'refresh_token': 'rt',
      },
    };

    test('fromJson parses user and tokens', () {
      final resp = AuthResponse.fromJson(json);
      expect(resp.user.id, 'u1');
      expect(resp.tokens.accessToken, 'at');
      expect(resp.tokens.refreshToken, 'rt');
    });

    test('requiresPhoneVerification defaults to false', () {
      final resp = AuthResponse.fromJson(json);
      expect(resp.requiresPhoneVerification, false);
    });

    test('requiresPhoneVerification from json', () {
      final withVerif = {
        ...json,
        'requiresPhoneVerification': true,
      };
      final resp = AuthResponse.fromJson(withVerif);
      expect(resp.requiresPhoneVerification, true);
    });
  });
}
