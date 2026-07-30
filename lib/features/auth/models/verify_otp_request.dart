class VerifyOtpRequest {
  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
    this.name,
    this.purpose = 'login',
  });

  final String phone;
  final String otp;
  final String? name;
  final String purpose;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        // Backend expects the field name "code" (see OtpController@verify).
        'code': otp,
        if (name != null && name!.isNotEmpty) 'name': name,
        'purpose': purpose,
      };
}
