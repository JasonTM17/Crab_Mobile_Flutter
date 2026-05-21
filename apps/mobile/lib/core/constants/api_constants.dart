class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authPhoneLogin = '/auth/login/phone';
  static const String authPhoneVerify = '/auth/login/phone/verify';
  static const String authVerifyPhone = '/auth/verify-phone';
  static const String authPasswordResetRequest = '/auth/password-reset/request';
  static const String authPasswordResetConfirm = '/auth/password-reset/confirm';
  static const String authChangePassword = '/auth/change-password';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  // User
  static const String profile = '/profiles';
  static const String addresses = '/addresses';

  // Ride
  static const String rides = '/rides';
  static const String fareEstimate = '/rides/estimate';
  static const String driverBase = '/drivers';

  // Food
  static const String restaurants = '/restaurants';
  static const String menus = '/menus';
  static const String orders = '/orders';

  // Payment
  static const String wallet = '/wallet';
  static const String transactions = '/transactions';

  // Chat
  static const String chats = '/chats';

  // Notifications
  static const String notifications = '/notifications';

  // Ratings
  static const String ratings = '/ratings';

  // Socket namespaces
  static const String rideNamespace = '/ride';
  static const String foodNamespace = '/food';
  static const String chatNamespace = '/chat';
  static const String notificationNamespace = '/notification';
}
