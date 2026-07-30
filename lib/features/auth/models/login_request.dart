/// Login request body (email or Afghan phone + password).
class LoginRequest {
  const LoginRequest({
    required this.identifier,
    required this.password,
  });

  final String identifier;
  final String password;

  Map<String, dynamic> toJson() => {
        'login': identifier,
        'password': password,
      };
}
