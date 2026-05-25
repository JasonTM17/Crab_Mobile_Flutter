import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_event.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';
import 'package:crab_mobile/features/payment/data/models/payment_models.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockPaymentRepository mockRepo;

  setUp(() {
    mockRepo = MockPaymentRepository();
  });

  group('PaymentBloc', () {
    test('initial state is PaymentInitial', () {
      final bloc = PaymentBloc(mockRepo);
      expect(bloc.state, isA<PaymentInitial>());
      bloc.close();
    });

    group('LoadWallet', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, WalletLoaded] on success',
        build: () {
          when(() => mockRepo.getWallet()).thenAnswer((_) async => tWallet);
          when(() => mockRepo.getTransactions(page: any(named: 'page')))
              .thenAnswer((_) async => <TransactionModel>[]);
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const LoadWallet()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<WalletLoaded>()
              .having((s) => s.wallet.balance, 'balance', 500000),
        ],
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] on failure',
        build: () {
          when(() => mockRepo.getWallet()).thenThrow(Exception('Error'));
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const LoadWallet()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>(),
        ],
      );
    });

    group('TopUpWallet', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, TopUpSuccess] on success',
        build: () {
          final updated = WalletModel(
            id: tWallet.id,
            userId: tWallet.userId,
            balance: tWallet.balance + 100000,
            currency: 'VND',
            updatedAt: DateTime.now(),
          );
          when(() => mockRepo.topUp(amount: 100000, method: 'momo'))
              .thenAnswer((_) async => updated);
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(
          const TopUpWallet(amount: 100000, method: 'momo'),
        ),
        expect: () => [
          isA<PaymentLoading>(),
          isA<TopUpSuccess>()
              .having((s) => s.wallet.balance, 'balance', 600000),
        ],
      );
    });

    group('LoadTransactions', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits transaction list on success',
        build: () {
          when(() => mockRepo.getTransactions(page: 1))
              .thenAnswer((_) async => [tTransaction, tTransaction2]);
          return PaymentBloc(mockRepo);
        },
        seed: () => WalletLoaded(wallet: tWallet, transactions: const []),
        act: (bloc) => bloc.add(const LoadTransactions(page: 1)),
        expect: () => [
          isA<WalletLoaded>().having((s) => s.transactions.length, 'txns', 2),
        ],
      );
    });

    group('LoadPromos', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PromosLoaded] on success',
        build: () {
          when(() => mockRepo.getAvailablePromos())
              .thenAnswer((_) async => [tPromo]);
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const LoadPromos()),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PromosLoaded>().having((s) => s.promos.length, 'promos', 1),
        ],
      );
    });

    group('ApplyPromoCode', () {
      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PromoApplied] on success',
        build: () {
          when(() => mockRepo.applyPromo('GRAB50K'))
              .thenAnswer((_) async => tPromo);
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const ApplyPromoCode(code: 'GRAB50K')),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PromoApplied>().having((s) => s.promo.code, 'code', 'GRAB50K'),
        ],
      );

      blocTest<PaymentBloc, PaymentState>(
        'emits [PaymentLoading, PaymentError] on invalid promo',
        build: () {
          when(() => mockRepo.applyPromo('INVALID'))
              .thenThrow(Exception('Promo not found'));
          return PaymentBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const ApplyPromoCode(code: 'INVALID')),
        expect: () => [
          isA<PaymentLoading>(),
          isA<PaymentError>(),
        ],
      );
    });
  });
}
