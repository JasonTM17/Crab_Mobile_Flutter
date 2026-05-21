import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/food/data/models/order_model.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_bloc.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_event.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockFoodRepository mockRepo;
  late MockSocketClient mockSocket;

  setUp(() {
    mockRepo = MockFoodRepository();
    mockSocket = MockSocketClient();
  });

  group('FoodBloc', () {
    test('initial state is FoodInitial', () {
      final bloc = FoodBloc(mockRepo, mockSocket);
      expect(bloc.state, isA<FoodInitial>());
      bloc.close();
    });

    // ═════════════════════════════════════════════════════
    // LoadRestaurants
    // ═════════════════════════════════════════════════════
    group('LoadRestaurants', () {
      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, RestaurantListLoaded] on success',
        build: () {
          when(() => mockRepo.getRestaurants(category: any(named: 'category')))
              .thenAnswer((_) async => [tRestaurant, tRestaurant2]);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadRestaurants()),
        expect: () => [
          isA<FoodLoading>(),
          isA<RestaurantListLoaded>()
              .having((s) => s.restaurants.length, 'count', 2),
        ],
      );

      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, RestaurantListLoaded] with category filter',
        build: () {
          when(() => mockRepo.getRestaurants(category: 'Vietnamese'))
              .thenAnswer((_) async => [tRestaurant]);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadRestaurants(category: 'Vietnamese')),
        expect: () => [
          isA<FoodLoading>(),
          isA<RestaurantListLoaded>()
              .having((s) => s.restaurants.length, 'count', 1),
        ],
      );

      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, FoodError] on failure',
        build: () {
          when(() => mockRepo.getRestaurants(category: any(named: 'category')))
              .thenThrow(Exception('Network error'));
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadRestaurants()),
        expect: () => [
          isA<FoodLoading>(),
          isA<FoodError>(),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // LoadRestaurantMenu
    // ═════════════════════════════════════════════════════
    group('LoadRestaurantMenu', () {
      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, RestaurantMenuLoaded] on success',
        build: () {
          when(() => mockRepo.getMenu(tRestaurant.id))
              .thenAnswer((_) async => [tMenuItem, tMenuItem2]);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) =>
            bloc.add(const LoadRestaurantMenu(restaurant: tRestaurant)),
        expect: () => [
          isA<FoodLoading>(),
          isA<RestaurantMenuLoaded>()
              .having((s) => s.menuItems.length, 'items', 2)
              .having((s) => s.restaurant.id, 'restId', tRestaurant.id),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // LoadOrderHistory
    // ═════════════════════════════════════════════════════
    group('LoadOrderHistory', () {
      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, OrderHistoryLoaded] on success',
        build: () {
          when(() => mockRepo.getOrderHistory())
              .thenAnswer((_) async => [tOrderModel, tOrderModelDelivered]);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadOrderHistory()),
        expect: () => [
          isA<FoodLoading>(),
          isA<OrderHistoryLoaded>().having((s) => s.orders.length, 'count', 2),
        ],
      );

      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, OrderHistoryLoaded] with empty list',
        build: () {
          when(() => mockRepo.getOrderHistory()).thenAnswer((_) async => []);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadOrderHistory()),
        expect: () => [
          isA<FoodLoading>(),
          isA<OrderHistoryLoaded>()
              .having((s) => s.orders.isEmpty, 'empty', true),
        ],
      );

      blocTest<FoodBloc, FoodState>(
        'emits [FoodLoading, FoodError] on failure',
        build: () {
          when(() => mockRepo.getOrderHistory())
              .thenThrow(Exception('Server error'));
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadOrderHistory()),
        expect: () => [
          isA<FoodLoading>(),
          isA<FoodError>(),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // LoadActiveOrder
    // ═════════════════════════════════════════════════════
    group('LoadActiveOrder', () {
      blocTest<FoodBloc, FoodState>(
        'emits OrderTracking when active order exists',
        build: () {
          when(() => mockRepo.getActiveOrder())
              .thenAnswer((_) async => tOrderModel);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadActiveOrder()),
        expect: () => [
          isA<OrderTracking>()
              .having((s) => s.order.id, 'orderId', tOrderModel.id),
        ],
      );

      blocTest<FoodBloc, FoodState>(
        'emits FoodInitial when no active order',
        build: () {
          when(() => mockRepo.getActiveOrder()).thenAnswer((_) async => null);
          return FoodBloc(mockRepo, mockSocket);
        },
        act: (bloc) => bloc.add(const LoadActiveOrder()),
        expect: () => <FoodState>[],
      );
    });

    // ═════════════════════════════════════════════════════
    // CancelOrder
    // ═════════════════════════════════════════════════════
    group('CancelOrder', () {
      blocTest<FoodBloc, FoodState>(
        'calls cancelOrder and updates order status to cancelled',
        build: () {
          when(() => mockRepo.cancelOrder('order-uuid-001'))
              .thenAnswer((_) async {});
          return FoodBloc(mockRepo, mockSocket);
        },
        seed: () => OrderTracking(order: tOrderModel),
        act: (bloc) => bloc.add(const CancelOrder(orderId: 'order-uuid-001')),
        expect: () => [
          isA<OrderTracking>().having(
            (s) => s.order.status,
            'status',
            OrderStatus.cancelled,
          ),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // OrderStatusUpdated
    // ═════════════════════════════════════════════════════
    group('OrderStatusUpdated', () {
      blocTest<FoodBloc, FoodState>(
        'updates order status in OrderTracking state',
        build: () => FoodBloc(mockRepo, mockSocket),
        seed: () => OrderTracking(order: tOrderModel),
        act: (bloc) => bloc.add(const OrderStatusUpdated(
          orderId: 'order-uuid-001',
          status: 'preparing',
          estimatedMinutes: 20,
        )),
        expect: () => [
          isA<OrderTracking>()
              .having((s) => s.order.status, 'status', OrderStatus.preparing),
        ],
      );
    });
  });
}
