import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/food/data/models/restaurant_model.dart';
import 'package:crab_mobile/features/food/data/models/cart_model.dart';
import 'package:crab_mobile/features/food/data/models/order_model.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_event.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';
import 'package:crab_mobile/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:crab_mobile/features/food/presentation/screens/order_history_screen.dart';

import 'helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tRestaurant = RestaurantModel(
    id: 'r1',
    name: 'Phở 24',
    category: 'Vietnamese',
    rating: 4.5,
    totalReviews: 320,
    deliveryTimeMinutes: 25,
    deliveryFee: 15000,
    minOrderAmount: 30000,
    isOpen: true,
    distanceKm: 1.2,
  );

  const tRestaurant2 = RestaurantModel(
    id: 'r2',
    name: 'Bún Bò Huế',
    category: 'Vietnamese',
    rating: 4.3,
    totalReviews: 180,
    deliveryTimeMinutes: 30,
    deliveryFee: 12000,
    minOrderAmount: 25000,
    isOpen: true,
  );

  final tOrderModel = OrderModel(
    id: 'o1',
    restaurantId: 'r1',
    restaurantName: 'Phở 24',
    items: [
      const OrderItemModel(
        menuItemId: 'm1',
        name: 'Phở Bò',
        price: 55000,
        quantity: 2,
      ),
    ],
    status: OrderStatus.confirmed,
    subtotal: 110000,
    deliveryFee: 15000,
    total: 125000,
    deliveryAddress: '123 Le Loi',
    createdAt: DateTime(2026, 5, 20, 12, 0, 0),
    estimatedMinutes: 30,
  );

  group('Food Ordering Flow E2E Integration', () {
    testWidgets('Restaurant list screen shows restaurants', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.foodBloc.state).thenReturn(
        const RestaurantListLoaded(
          restaurants: [tRestaurant, tRestaurant2],
          cart: CartModel(),
        ),
      );

      await tester.pumpWidget(
        app.buildWidget(const RestaurantListScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phở 24'), findsOneWidget);
      expect(find.text('Bún Bò Huế'), findsOneWidget);
      expect(find.text('2 restaurants nearby'), findsOneWidget);
    });

    testWidgets('Restaurant list shows loading state', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.foodBloc.state).thenReturn(const FoodLoading());

      await tester.pumpWidget(
        app.buildWidget(const RestaurantListScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Restaurant list shows error with retry', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.foodBloc.state).thenReturn(
        const FoodError(message: 'Network error'),
      );

      await tester.pumpWidget(
        app.buildWidget(const RestaurantListScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
      final retryBtn = find.textContaining(RegExp(r'[Rr]etry|[Tt]hử [Ll]ại'));
      expect(retryBtn, findsOneWidget);

      await tester.tap(retryBtn);
      await tester.pump();

      verify(() => app.foodBloc.add(const LoadRestaurants())).called(2);
    });

    testWidgets('Order history shows delivered and active orders',
        (tester) async {
      final app = TestApp();
      app.stubDefaults();

      final delivered = tOrderModel.copyWith(status: OrderStatus.delivered);
      when(() => app.foodBloc.state).thenReturn(
        OrderHistoryLoaded(orders: [tOrderModel, delivered]),
      );

      await tester.pumpWidget(
        app.buildWidget(const OrderHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phở 24'), findsAtLeast(1));
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('Order history empty state', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.foodBloc.state).thenReturn(
        const OrderHistoryLoaded(orders: []),
      );

      await tester.pumpWidget(
        app.buildWidget(const OrderHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('Order history shows track button for active orders',
        (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.foodBloc.state).thenReturn(
        OrderHistoryLoaded(orders: [tOrderModel]),
      );

      await tester.pumpWidget(
        app.buildWidget(const OrderHistoryScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Track'), findsOneWidget);
    });

    testWidgets('Order status transitions via BLoC stream', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      whenListen(
        app.foodBloc,
        Stream.fromIterable([
          OrderTracking(order: tOrderModel),
          OrderTracking(
            order: tOrderModel.copyWith(status: OrderStatus.preparing),
          ),
          OrderTracking(
            order: tOrderModel.copyWith(status: OrderStatus.delivered),
          ),
        ]),
        initialState: const FoodInitial(),
      );

      await expectLater(
        app.foodBloc.stream,
        emitsInOrder([
          isA<OrderTracking>().having(
            (state) => state.order.status,
            'status',
            OrderStatus.confirmed,
          ),
          isA<OrderTracking>().having(
            (state) => state.order.status,
            'status',
            OrderStatus.preparing,
          ),
          isA<OrderTracking>().having(
            (state) => state.order.status,
            'status',
            OrderStatus.delivered,
          ),
        ]),
      );
    });
  });
}
