// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../network/dio_client.dart' as _i1;
import '../network/socket_client.dart' as _i2;
import '../../features/auth/data/repositories/auth_repository.dart' as _i3;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i4;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i5;

extension GetItInjectableX on _i174.GetIt {
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i1.DioClient>(() => _i1.DioClient());
    gh.singleton<_i2.SocketClient>(() => _i2.SocketClient());
    gh.singleton<_i3.AuthRepository>(
      () => _i3.AuthRepository(gh<_i1.DioClient>()),
    );
    gh.factory<_i4.AuthBloc>(
      () => _i4.AuthBloc(gh<_i3.AuthRepository>()),
    );
    gh.factory<_i5.HomeBloc>(() => _i5.HomeBloc());
    return this;
  }
}
