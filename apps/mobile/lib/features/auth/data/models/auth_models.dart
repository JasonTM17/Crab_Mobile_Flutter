class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}

class UserModel {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String status;
  final String? avatarUrl;
  final bool phoneVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.phoneVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        phoneVerified: json['phoneVerified'] as bool? ?? false,
      );

  String get fullName => '$firstName $lastName';
}

class AuthResponse {
  final UserModel user;
  final AuthTokens tokens;
  final bool requiresPhoneVerification;

  AuthResponse({
    required this.user,
    required this.tokens,
    this.requiresPhoneVerification = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
        requiresPhoneVerification: json['requiresPhoneVerification'] as bool? ?? false,
      );
}
