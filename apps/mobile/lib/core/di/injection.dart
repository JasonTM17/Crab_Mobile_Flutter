import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/socket_client.dart';
import '../../shared/services/auth_storage.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/home/presentation/bloc/home_bloc.dart';

import '../../features/ride/data/repositories/ride_repository.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';

import '../../features/ride/driver/data/repositories/driver_repository.dart';
import '../../features/ride/driver/presentation/bloc/driver_bloc.dart';

import '../../features/food/data/repositories/food_repository.dart';
import '../../features/food/presentation/bloc/food_bloc.dart';

import '../../features/payment/data/repositories/payment_repository.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

import '../../features/rating/data/repositories/rating_repository.dart';
import '../../features/rating/presentation/bloc/rating_bloc.dart';

import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Storage ────────────────────────────────────────────────
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthStorage>(
    () => AuthStorage(sl<FlutterSecureStorage>()),
  );

  // ── Networking ─────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(
    () => DioClient.create(authStorage: sl<AuthStorage>()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<Dio>()),
  );

  sl.registerLazySingleton<SocketClient>(
    () => SocketClient(authStorage: sl<AuthStorage>()),
  );

  // ── Repositories ───────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dio: sl<Dio>(), storage: sl<AuthStorage>()),
  );

  sl.registerLazySingleton<RideRepository>(
    () => RideRepository(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<RatingRepository>(
    () => RatingRepository(sl<DioClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(sl<DioClient>()),
  );

  // ── Blocs (factory: fresh instance per screen) ─────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: sl<AuthRepository>()),
  );

  sl.registerFactory<HomeBloc>(() => HomeBloc());

  sl.registerFactory<RideBloc>(
    () => RideBloc(sl<RideRepository>()),
  );

  sl.registerFactory<DriverBloc>(
    () => DriverBloc(sl<DriverRepository>()),
  );

  sl.registerFactory<FoodBloc>(
    () => FoodBloc(sl<FoodRepository>(), sl<SocketClient>()),
  );

  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(sl<PaymentRepository>()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl<ChatRepository>(), sl<SocketClient>()),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(sl<NotificationRepository>(), sl<SocketClient>()),
  );

  sl.registerFactory<RatingBloc>(
    () => RatingBloc(sl<RatingRepository>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(sl<ProfileRepository>(), sl<FlutterSecureStorage>()),
  );
}
