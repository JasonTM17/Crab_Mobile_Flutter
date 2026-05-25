// ignore_for_file: subtype_of_sealed_class

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crab_mobile/core/theme/app_theme.dart';

import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_bloc.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_bloc.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_bloc.dart';

import 'mocks.dart';

/// Builds a [MaterialApp] wrapping [child] with all 10 [BlocProvider]s.
Widget buildTestApp({
  required Widget child,
  required MockAuthBloc authBloc,
  required MockHomeBloc homeBloc,
  required MockRideBloc rideBloc,
  required MockDriverBloc driverBloc,
  required MockFoodBloc foodBloc,
  required MockPaymentBloc paymentBloc,
  required MockChatBloc chatBloc,
  required MockNotificationBloc notificationBloc,
  required MockProfileBloc profileBloc,
  required MockRatingBloc ratingBloc,
}) {
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
