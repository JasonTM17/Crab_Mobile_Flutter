import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../../shared/services/auth_storage.dart';

class DioClient {
  static Dio create({required AuthStorage authStorage}) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh token
          final refreshToken = await authStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                '${ApiConstants.baseUrl}${ApiConstants.authRefresh}',
                data: {'refresh_token': refreshToken},
              );
              final newAccess = response.data['tokens']['access_token'] as String;
              final newRefresh = response.data['tokens']['refresh_token'] as String;
              await authStorage.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );
              // Retry original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retry = await dio.fetch(error.requestOptions);
              return handler.resolve(retry);
            } catch (_) {
              await authStorage.clear();
            }
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}
