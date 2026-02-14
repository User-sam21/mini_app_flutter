
class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;
  final String? country;
  final String? currency;
  final String? language;
  final bool isEmailVerified;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
    this.country,
    this.currency,
    this.language,
    this.isEmailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      country: json['country'],
      currency: json['currency'],
      language: json['language'],
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'country': country,
      'currency': currency,
      'language': language,
      'isEmailVerified': isEmailVerified,
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? country,
    String? currency,
    String? language,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

class AuthResponse {
  final String userId;
  final String token;
  final bool requiresEmailVerification;

  AuthResponse({
    required this.userId,
    required this.token,
    required this.requiresEmailVerification,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'],
      token: json['token'],
      requiresEmailVerification: json['requiresEmailVerification'] ?? true,
    );
  }
}

class OtpResponse {
  final bool success;
  final int expiresIn;

  OtpResponse({
    required this.success,
    required this.expiresIn,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'],
      expiresIn: json['expiresIn'],
    );
  }
}