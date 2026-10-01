class SocialLoginModel {
  final String authProvider; // 'google', 'facebook', 'apple'
  final String socialId;
  final String userName;
  final String email;
  final String? image;
  final String? fcmToken;
  final String? token;
  final String? role;

  SocialLoginModel({
    required this.authProvider,
    required this.socialId,
    required this.userName,
    required this.email,
    this.image,
    this.fcmToken,
    this.token,
    this.role,
  });

  SocialLoginModel copyWith({String? role}) {
    return SocialLoginModel(
      authProvider: authProvider,
      socialId: socialId,
      userName: userName,
      email: email,
      image: image,
      fcmToken: fcmToken,
      token: token,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authProvider': authProvider,
      'socialId': socialId,
      'userName': userName,
      // The server takes the email from the provider's verified token and
      // ignores this; an empty string would fail its @IsEmail check.
      if (email.isNotEmpty) 'email': email,
      if (image != null) 'image': image,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (token != null) 'token': token,
      if (role != null) 'role': role,
    };
  }
}
