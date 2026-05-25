import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/api_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/ride/presentation/bloc/ride_bloc.dart';
import 'features/ride/driver/presentation/bloc/driver_bloc.dart';
import 'features/food/presentation/bloc/food_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/rating/presentation/bloc/rating_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConstants.validateReleaseConfiguration();
  await configureDependencies();
  runApp(const CrabApp());
}

class CrabApp extends StatelessWidget {
  const CrabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<RideBloc>(create: (_) => sl<RideBloc>()),
        BlocProvider<DriverBloc>(create: (_) => sl<DriverBloc>()),
        BlocProvider<FoodBloc>(create: (_) => sl<FoodBloc>()),
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => sl<NotificationBloc>(),
        ),
        BlocProvider<RatingBloc>(create: (_) => sl<RatingBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Crab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
