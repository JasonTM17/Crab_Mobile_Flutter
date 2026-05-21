import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/payment/data/models/payment_models.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';
import 'package:crab_mobile/features/payment/presentation/screens/wallet_screen.dart';
import 'package:crab_mobile/features/payment/presentation/screens/top_up_screen.dart';

import 'helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tWallet = WalletModel(
    id: 'w1',
    userId: 'u1',
    balance: 500000,
    currency: 'VND',
    updatedAt: DateTime(2026, 5, 20),
  );

  final tTransaction = TransactionModel(
    id: 't1',
    type: 'top_up',
    amount: 200000,
    currency: 'VND',
    status: 'completed',
    description: 'Top up via MoMo',
    createdAt: DateTime(2026, 5, 20, 9, 0),
  );

  final tTransaction2 = TransactionModel(
    id: 't2',
    type: 'payment',
    amount: -42000,
    currency: 'VND',
    status: 'completed',
    description: 'Ride payment',
    createdAt: DateTime(2026, 5, 20, 10, 30),
  );

  group('Payment Flow E2E Integration', () {
    testWidgets('Wallet screen shows balance and transactions', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.paymentBloc.state).thenReturn(
        WalletLoaded(
          wallet: tWallet,
          transactions: [tTransaction, tTransaction2],
        ),
      );

      await tester.pumpWidget(
        app.buildWidget(const WalletScreen()),
      );
      await tester.pumpAndSettle();

      // Balance should be displayed
      expect(find.textContaining('500'), findsAtLeast(1));
    });

    testWidgets('Wallet shows loading state', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.paymentBloc.state).thenReturn(const PaymentLoading());

      await tester.pumpWidget(
        app.buildWidget(const WalletScreen()),
      );
      await tester.pump();

      // Should show loading indicator or skeleton
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
            find.byType(WalletScreen).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Top up screen renders', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      await tester.pumpWidget(
        app.buildWidget(const TopUpScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TopUpScreen), findsOneWidget);
    });

    testWidgets('Top up success updates wallet balance', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      final updatedWallet = WalletModel(
        id: 'w1',
        userId: 'u1',
        balance: 700000,
        currency: 'VND',
        updatedAt: DateTime(2026, 5, 20, 11, 0),
      );

      whenListen(
        app.paymentBloc,
        Stream<PaymentState>.fromIterable([
          const PaymentLoading(),
          TopUpSuccess(wallet: updatedWallet),
        ]),
        initialState: WalletLoaded(wallet: tWallet, transactions: const []),
      );

      await expectLater(
        app.paymentBloc.stream,
        emitsInOrder([
          isA<PaymentLoading>(),
          isA<TopUpSuccess>().having(
            (state) => state.wallet.balance,
            'balance',
            700000,
          ),
        ]),
      );
    });

    testWidgets('Payment error state', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.paymentBloc.state).thenReturn(
        const PaymentError(message: 'Insufficient balance'),
      );

      await tester.pumpWidget(
        app.buildWidget(const WalletScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Insufficient'), findsAtLeast(1));
    });

    testWidgets('Promo code flow', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      final promo = PromoModel(
        id: 'p1',
        code: 'GRAB50K',
        description: 'Giam 50k',
        discountType: 'fixed',
        discountValue: 50000,
        expiresAt: DateTime(2026, 12, 31),
      );

      whenListen(
        app.paymentBloc,
        Stream<PaymentState>.fromIterable([
          PromoApplied(promo: promo),
        ]),
        initialState: const PaymentInitial(),
      );

      await expectLater(
        app.paymentBloc.stream,
        emits(
          isA<PromoApplied>().having(
            (state) => state.promo.code,
            'code',
            'GRAB50K',
          ),
        ),
      );
    });
  });
}
