class SendOtpRequest {
  const SendOtpRequest({
    required this.phone,
  });

  final String phone;

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}
