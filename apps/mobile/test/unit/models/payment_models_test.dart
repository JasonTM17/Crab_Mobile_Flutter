import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/payment/data/models/payment_models.dart';

void main() {
  group('WalletModel', () {
    final json = {
      'id': 'w1',
      'userId': 'u1',
      'balance': 500000,
      'currency': 'VND',
      'updatedAt': '2026-05-20T00:00:00.000',
    };

    test('fromJson parses all fields', () {
      final w = WalletModel.fromJson(json);
      expect(w.id, 'w1');
      expect(w.userId, 'u1');
      expect(w.balance, 500000);
      expect(w.currency, 'VND');
      expect(w.updatedAt, DateTime(2026, 5, 20));
    });

    test('supports equality', () {
      final a = WalletModel.fromJson(json);
      final b = WalletModel.fromJson(json);
      expect(a.id, b.id);
      expect(a.balance, b.balance);
    });
  });

  group('TransactionModel', () {
    final json = {
      'id': 't1',
      'type': 'top_up',
      'amount': 200000,
      'currency': 'VND',
      'status': 'completed',
      'description': 'Top up via MoMo',
      'createdAt': '2026-05-20T09:00:00.000',
    };

    test('fromJson parses required fields', () {
      final tx = TransactionModel.fromJson(json);
      expect(tx.id, 't1');
      expect(tx.type, 'top_up');
      expect(tx.amount, 200000);
      expect(tx.currency, 'VND');
      expect(tx.status, 'completed');
      expect(tx.description, 'Top up via MoMo');
      expect(tx.createdAt, DateTime(2026, 5, 20, 9, 0, 0));
    });

    test('fromJson handles null reference fields', () {
      final tx = TransactionModel.fromJson(json);
      expect(tx.referenceId, isNull);
      expect(tx.referenceType, isNull);
    });

    test('fromJson parses reference fields', () {
      final withRef = {
        ...json,
        'referenceId': 'ride-001',
        'referenceType': 'ride',
      };
      final tx = TransactionModel.fromJson(withRef);
      expect(tx.referenceId, 'ride-001');
      expect(tx.referenceType, 'ride');
    });

    test('negative amounts for payments', () {
      final paymentJson = {
        ...json,
        'type': 'payment',
        'amount': -42000,
      };
      final tx = TransactionModel.fromJson(paymentJson);
      expect(tx.amount, -42000);
    });
  });

  group('PromoModel', () {
    final json = {
      'id': 'p1',
      'code': 'GRAB50K',
      'description': 'Giam 50k',
      'discountType': 'fixed',
      'discountValue': 50000,
      'maxDiscount': 50000,
      'minOrderAmount': 100000,
      'expiresAt': '2026-12-31T00:00:00.000',
    };

    test('fromJson parses all fields', () {
      final p = PromoModel.fromJson(json);
      expect(p.id, 'p1');
      expect(p.code, 'GRAB50K');
      expect(p.description, 'Giam 50k');
      expect(p.discountType, 'fixed');
      expect(p.discountValue, 50000);
      expect(p.maxDiscount, 50000);
      expect(p.minOrderAmount, 100000);
      expect(p.expiresAt, DateTime(2026, 12, 31));
    });

    test('fromJson handles null optionals', () {
      final minimal = {
        'id': 'p2',
        'code': 'X',
        'description': 'Y',
        'discountType': 'percentage',
        'discountValue': 10,
        'expiresAt': '2026-06-01T00:00:00.000',
      };
      final p = PromoModel.fromJson(minimal);
      expect(p.maxDiscount, isNull);
      expect(p.minOrderAmount, isNull);
    });

    test('percentage discount type', () {
      final pctJson = {
        ...json,
        'discountType': 'percentage',
        'discountValue': 15,
      };
      final p = PromoModel.fromJson(pctJson);
      expect(p.discountType, 'percentage');
      expect(p.discountValue, 15);
    });
  });
}
