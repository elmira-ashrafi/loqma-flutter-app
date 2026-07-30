/// Register request body.
class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.password,
    required this.phone,
    this.email,
    this.address,
    this.passwordConfirmation,
    this.latitude,
    this.longitude,
    this.city,
  });

  final String name;
  final String? email;
  final String password;
  final String phone;
  final String? address;
  final String? passwordConfirmation;
  final double? latitude;
  final double? longitude;
  final String? city;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation ?? password,
    };
    final emailTrim = email?.trim();
    if (emailTrim != null && emailTrim.isNotEmpty) {
      map['email'] = emailTrim.toLowerCase();
    }
    final addressTrim = address?.trim();
    if (addressTrim != null && addressTrim.isNotEmpty) {
      map['address'] = addressTrim;
    }
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (city != null && city!.trim().isNotEmpty) map['city'] = city!.trim();
    return map;
  }
}

/// Complete profile for Google users missing phone/name.
class CompleteProfileRequest {
  const CompleteProfileRequest({
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
  });

  final String name;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
    };
    if (address != null && address!.trim().isNotEmpty) {
      map['address'] = address!.trim();
    }
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (city != null && city!.trim().isNotEmpty) map['city'] = city!.trim();
    return map;
  }
}

/// Forgot password via email OTP (legacy).
class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email.trim().toLowerCase()};
}

/// Request admin to assign a temporary password (name + phone).
class AdminPasswordResetRequest {
  const AdminPasswordResetRequest({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {
        'name': name.trim().replaceAll(RegExp(r'\s+'), ' '),
        'phone': phone.trim(),
      };
}

/// Reset password with email verification code.
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.password,
    this.passwordConfirmation,
  });

  final String email;
  final String otp;
  final String password;
  final String? passwordConfirmation;

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation ?? password,
      };
}

/// Cooldown metadata returned by forgot-password.
class ForgotPasswordResult {
  const ForgotPasswordResult({
    required this.email,
    this.resendCooldownSeconds = 60,
    this.expiresInSeconds,
  });

  final String email;
  final int resendCooldownSeconds;
  final int? expiresInSeconds;

  factory ForgotPasswordResult.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResult(
      email: json['email'] as String? ?? '',
      resendCooldownSeconds:
          (json['resend_cooldown_seconds'] as num?)?.toInt() ?? 60,
      expiresInSeconds: (json['expires_in_seconds'] as num?)?.toInt(),
    );
  }
}

/// Result of admin password-reset request.
class AdminPasswordResetResult {
  const AdminPasswordResetResult({
    this.requestId,
    this.status = 'pending',
    this.message,
  });

  final int? requestId;
  final String status;
  final String? message;

  factory AdminPasswordResetResult.fromJson(Map<String, dynamic> json) {
    return AdminPasswordResetResult(
      requestId: (json['request_id'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
    );
  }
}

/// Temporary password assigned by admin, shown on login.
class TemporaryPasswordStatus {
  const TemporaryPasswordStatus({
    required this.hasTemporaryPassword,
    this.temporaryPassword,
    this.message,
  });

  final bool hasTemporaryPassword;
  final String? temporaryPassword;
  final String? message;

  factory TemporaryPasswordStatus.fromJson(Map<String, dynamic> json) {
    return TemporaryPasswordStatus(
      hasTemporaryPassword: json['has_temporary_password'] == true,
      temporaryPassword: json['temporary_password'] as String?,
      message: json['message'] as String?,
    );
  }
}
