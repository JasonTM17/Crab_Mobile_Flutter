import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/food/data/repositories/food_repository.dart';
import '../../features/food/presentation/bloc/food_bloc.dart';
import '../../features/food/presentation/screens/restaurant_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';
import '../../features/ride/presentation/screens/ride_booking_screen.dart';
import '../../features/ride/driver/presentation/bloc/driver_bloc.dart';
import '../../features/ride/driver/presentation/screens/driver_mode_screen.dart';
import '../constants/api_constants.dart';
import '../di/injection.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String rideBooking = '/ride';
  static const String driverMode = '/driver';
  static const String food = '/food';

  static final _storage = const FlutterSecureStorage();

  static final GoRouter router = GoRouter(
    initialLocation: home,
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: rideBooking,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<RideBloc>(),
          child: const RideBookingScreen(),
        ),
      ),
      GoRoute(
        path: driverMode,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DriverBloc>(),
          child: const DriverModeScreen(),
        ),
      ),
      GoRoute(
        path: food,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<FoodBloc>(),
          child: const RestaurantListScreen(),
        ),
      ),
    ],
  );

  static Future<String?> _authRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final token = await _storage.read(key: ApiConstants.accessTokenKey);
    final isAuthenticated = token != null && token.isNotEmpty;
    final isOnAuthPage =
        state.matchedLocation == login ||
        state.matchedLocation == register;

    if (!isAuthenticated && !isOnAuthPage) {
      return login;
    }
    if (isAuthenticated && isOnAuthPage) {
      return home;
    }
    return null;
  }
}
