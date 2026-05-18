import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/socket_client.dart';
import '../../shared/services/auth_storage.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/ride/data/repositories/ride_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthStorage>(
    () => AuthStorage(sl<FlutterSecureStorage>()),
  );

  // Networking
  sl.registerLazySingleton<Dio>(
    () => DioClient.create(authStorage: sl<AuthStorage>()),
  );

  sl.registerLazySingleton<SocketClient>(
    () => SocketClient(authStorage: sl<AuthStorage>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dio: sl<Dio>(), storage: sl<AuthStorage>()),
  );

  sl.registerLazySingleton<RideRepository>(
    () => RideRepository(dio: sl<Dio>()),
  );
}
