class AccountDeletionRequestModel {
  const AccountDeletionRequestModel({
    required this.id,
    required this.status,
    this.reason,
    this.adminNote,
    this.createdAt,
    this.reviewedAt,
  });

  final int id;
  final String status;
  final String? reason;
  final String? adminNote;
  final String? createdAt;
  final String? reviewedAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  factory AccountDeletionRequestModel.fromJson(Map<String, dynamic> json) {
    return AccountDeletionRequestModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String?,
      adminNote: json['admin_note'] as String?,
      createdAt: json['created_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
    );
  }
}
