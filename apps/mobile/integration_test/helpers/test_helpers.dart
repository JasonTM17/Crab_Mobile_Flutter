// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/core/theme/app_theme.dart';

import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_state.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_event.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_state.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_bloc.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_event.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_state.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_bloc.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_event.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_event.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_state.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_state.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_bloc.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_event.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_state.dart';

// ═══════════════════════════════════════════════════════════════
// MOCK BLOCS
// ═══════════════════════════════════════════════════════════════

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockRideBloc extends MockBloc<RideEvent, RideState> implements RideBloc {}

class MockDriverBloc extends MockBloc<DriverEvent, DriverState>
    implements DriverBloc {}

class MockFoodBloc extends MockBloc<FoodEvent, FoodState> implements FoodBloc {}

class MockPaymentBloc extends MockBloc<PaymentEvent, PaymentState>
    implements PaymentBloc {}

class MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

class MockNotificationBloc
    extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockRatingBloc extends MockBloc<RatingEvent, RatingState>
    implements RatingBloc {}

// ═══════════════════════════════════════════════════════════════
// PUMP APP HELPER
// ═══════════════════════════════════════════════════════════════

class TestApp {
  final MockAuthBloc authBloc;
  final MockHomeBloc homeBloc;
  final MockRideBloc rideBloc;
  final MockDriverBloc driverBloc;
  final MockFoodBloc foodBloc;
  final MockPaymentBloc paymentBloc;
  final MockChatBloc chatBloc;
  final MockNotificationBloc notificationBloc;
  final MockProfileBloc profileBloc;
  final MockRatingBloc ratingBloc;

  TestApp()
      : authBloc = MockAuthBloc(),
        homeBloc = MockHomeBloc(),
        rideBloc = MockRideBloc(),
        driverBloc = MockDriverBloc(),
        foodBloc = MockFoodBloc(),
        paymentBloc = MockPaymentBloc(),
        chatBloc = MockChatBloc(),
        notificationBloc = MockNotificationBloc(),
        profileBloc = MockProfileBloc(),
        ratingBloc = MockRatingBloc();

  void stubDefaults() {
    when(() => authBloc.state).thenReturn(const AuthState());
    when(() => homeBloc.state).thenReturn(const HomeState());
    when(() => rideBloc.state).thenReturn(const RideIdle());
    when(() => driverBloc.state).thenReturn(const DriverOffline());
    when(() => foodBloc.state).thenReturn(const FoodInitial());
    when(() => paymentBloc.state).thenReturn(const PaymentInitial());
    when(() => chatBloc.state).thenReturn(const ChatInitial());
    when(() => notificationBloc.state).thenReturn(const NotificationInitial());
    when(() => profileBloc.state).thenReturn(const ProfileInitial());
    when(() => ratingBloc.state).thenReturn(const RatingInitial());
  }

  Widget buildWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<RideBloc>.value(value: rideBloc),
        BlocProvider<DriverBloc>.value(value: driverBloc),
        BlocProvider<FoodBloc>.value(value: foodBloc),
        BlocProvider<PaymentBloc>.value(value: paymentBloc),
        BlocProvider<ChatBloc>.value(value: chatBloc),
        BlocProvider<NotificationBloc>.value(value: notificationBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<RatingBloc>.value(value: ratingBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }
}

extension PumpApp on WidgetTester {
  Future<TestApp> pumpScreen(Widget screen) async {
    final app = TestApp()..stubDefaults();
    await pumpWidget(app.buildWidget(screen));
    return app;
  }
}
