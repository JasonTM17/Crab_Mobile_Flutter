import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/payment/data/repositories/payment_repository.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          create: (_) => AuthBloc(repository: sl<AuthRepository>())
            ..add(const AuthCheckRequested()),
        ),
        BlocProvider<PaymentBloc>(
          create: (_) => PaymentBloc(sl<PaymentRepository>()),
        ),
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
