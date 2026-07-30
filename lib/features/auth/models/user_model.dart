import 'package:equatable/equatable.dart';

/// User model from /me and auth responses.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.emailVerifiedAt,
    this.role,
    this.roles = const [],
    this.isDriver = false,
    this.profileComplete,
    this.mustChangePassword = false,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? emailVerifiedAt;

  /// Primary role string from backend (optional, e.g. "customer", "driver").
  final String? role;

  /// Additional roles, if backend returns an array like ["driver", "customer"].
  final List<String> roles;

  /// Convenience flag when backend exposes a boolean, or inferred from [role]/[roles].
  final bool isDriver;

  /// From backend `profile_complete`; when null, inferred from name + phone.
  final bool? profileComplete;

  /// Admin assigned a temporary password — user must change it before continuing.
  final bool mustChangePassword;

  bool get isProfileComplete {
    if (profileComplete != null) return profileComplete!;
    return name.trim().isNotEmpty && (phone?.trim().isNotEmpty ?? false);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final dynamic rawRoles = json['roles'];
    List<String> parsedRoles = const [];
    if (rawRoles is List) {
      parsedRoles = rawRoles.map((e) => e.toString()).toList();
    } else if (rawRoles is String && rawRoles.isNotEmpty) {
      parsedRoles = [rawRoles];
    }
    final String? role = json['role'] as String?;
    final bool isDriverFlag = json['is_driver'] == true ||
        parsedRoles.contains('driver') ||
        role == 'driver';

    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: role,
      roles: parsedRoles,
      isDriver: isDriverFlag,
      profileComplete: json['profile_complete'] as bool?,
      mustChangePassword: json['must_change_password'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'email_verified_at': emailVerifiedAt,
        'role': role,
        'roles': roles,
        'is_driver': isDriver,
        'profile_complete': profileComplete,
        'must_change_password': mustChangePassword,
      };

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? emailVerifiedAt,
    String? role,
    List<String>? roles,
    bool? isDriver,
    bool? profileComplete,
    bool? mustChangePassword,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      isDriver: isDriver ?? this.isDriver,
      profileComplete: profileComplete ?? this.profileComplete,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        role,
        roles,
        isDriver,
        profileComplete,
        mustChangePassword,
      ];
}
