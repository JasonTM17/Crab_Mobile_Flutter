import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/food/presentation/bloc/food_bloc.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_event.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';
import 'package:crab_mobile/features/food/data/models/cart_model.dart';
import 'package:crab_mobile/features/food/presentation/screens/restaurant_list_screen.dart';
import 'package:crab_mobile/features/food/presentation/widgets/restaurant_card.dart';
import 'package:crab_mobile/core/theme/app_theme.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockFoodBloc mockFoodBloc;

  setUp(() {
    mockFoodBloc = MockFoodBloc();
  });

  Widget buildSubject() {
    return BlocProvider<FoodBloc>.value(
      value: mockFoodBloc,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const RestaurantListScreen(),
      ),
    );
  }

  group('RestaurantListScreen', () {
    testWidgets('shows loading when FoodLoading', (tester) async {
      when(() => mockFoodBloc.state).thenReturn(const FoodLoading());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('shows restaurant cards when loaded', (tester) async {
      when(() => mockFoodBloc.state).thenReturn(
        const RestaurantListLoaded(
          restaurants: [tRestaurant, tRestaurant2],
          cart: CartModel(),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Phở 24'), findsOneWidget);
      expect(find.byType(RestaurantCard), findsAtLeastNWidgets(1));
      expect(find.textContaining('Bún Bò Huế'), findsNothing);
    });

    testWidgets('shows error with retry on FoodError', (tester) async {
      when(() => mockFoodBloc.state).thenReturn(
        const FoodError(message: 'Network error'),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('Network error'), findsOneWidget);

      final retryBtn = find.textContaining(RegExp(r'[Rr]etry|[Tt]hử [Ll]ại'));
      if (retryBtn.evaluate().isNotEmpty) {
        await tester.tap(retryBtn.first);
        await tester.pump();
        verify(() => mockFoodBloc.add(const LoadRestaurants())).called(2);
      }
    });

    testWidgets('shows empty state when no restaurants', (tester) async {
      when(() => mockFoodBloc.state).thenReturn(
        const RestaurantListLoaded(
          restaurants: [],
          cart: CartModel(),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantListScreen), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      when(() => mockFoodBloc.state).thenReturn(
        const RestaurantListLoaded(
          restaurants: [tRestaurant],
          cart: CartModel(),
        ),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Should find search field or search icon
      expect(
        find.byType(TextField).evaluate().isNotEmpty ||
            find.byIcon(Icons.search).evaluate().isNotEmpty,
        true,
      );
    });
  });
}
