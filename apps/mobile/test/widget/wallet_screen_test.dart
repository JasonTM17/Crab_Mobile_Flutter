import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';
import 'package:crab_mobile/features/payment/presentation/screens/wallet_screen.dart';
import 'package:crab_mobile/core/theme/app_theme.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockPaymentBloc mockPaymentBloc;

  setUp(() {
    mockPaymentBloc = MockPaymentBloc();
  });

  Widget buildSubject() {
    return BlocProvider<PaymentBloc>.value(
      value: mockPaymentBloc,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WalletScreen(),
      ),
    );
  }

  group('WalletScreen', () {
    testWidgets('shows loading when PaymentLoading', (tester) async {
      when(() => mockPaymentBloc.state).thenReturn(const PaymentLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('shows wallet balance when WalletLoaded', (tester) async {
      when(() => mockPaymentBloc.state).thenReturn(
        WalletLoaded(wallet: tWallet, transactions: []),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Balance should be displayed (500,000 or 500000)
      expect(find.textContaining('500'), findsAtLeast(1));
    });

    testWidgets('shows transactions when WalletLoaded', (tester) async {
      when(() => mockPaymentBloc.state).thenReturn(
        WalletLoaded(
          wallet: tWallet,
          transactions: [tTransaction, tTransaction2],
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Should find transaction descriptions
      expect(find.textContaining('MoMo'), findsAtLeast(1));
    });

    testWidgets('shows error when PaymentError', (tester) async {
      when(() => mockPaymentBloc.state).thenReturn(
        const PaymentError(message: 'Connection failed'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Connection failed'), findsOneWidget);
    });

    testWidgets('renders top up button', (tester) async {
      when(() => mockPaymentBloc.state).thenReturn(
        WalletLoaded(wallet: tWallet, transactions: []),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Find top up button
      final topUpBtn = find.textContaining(RegExp(r'[Tt]op [Uu]p|[Nn]ạp'));
      expect(topUpBtn, findsAtLeast(1));
    });
  });
}
