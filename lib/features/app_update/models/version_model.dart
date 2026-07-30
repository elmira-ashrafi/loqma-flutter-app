import 'package:equatable/equatable.dart';

/// Remote app version payload from GET /api/v1/app/version.
class VersionModel extends Equatable {
  const VersionModel({
    required this.latestVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.downloadUrl,
  });

  final String latestVersion;
  final bool forceUpdate;
  final String updateMessage;
  final String downloadUrl;

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      latestVersion: (json['latest_version'] as String?)?.trim() ?? '',
      forceUpdate: json['force_update'] as bool? ?? false,
      updateMessage: (json['update_message'] as String?)?.trim() ?? '',
      downloadUrl: (json['download_url'] as String?)?.trim() ?? '',
    );
  }

  bool get hasDownloadUrl => downloadUrl.isNotEmpty;

  @override
  List<Object?> get props => [latestVersion, forceUpdate, updateMessage, downloadUrl];
}
