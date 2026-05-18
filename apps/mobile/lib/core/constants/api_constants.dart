class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String profile = '/users/me';

  // Ride endpoints
  static const String rides = '/rides';
  static const String createRide = '/rides';
  static const String estimateFare = '/rides/estimate';
  static const String rideHistory = '/rides/history';
  static const String activeRide = '/rides/active';

  // Socket namespaces
  static const String rideNamespace = '/ride';
  static const String foodNamespace = '/food';
  static const String chatNamespace = '/chat';
  static const String notificationNamespace = '/notification';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
