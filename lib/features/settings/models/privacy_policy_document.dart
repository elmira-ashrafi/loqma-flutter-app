import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Parsed `assets/privacy/{locale}.json` for the privacy policy screen.
@immutable
class PrivacyPolicyDocument {
  const PrivacyPolicyDocument({required this.sections});

  factory PrivacyPolicyDocument.fromJson(Map<String, dynamic> json) {
    final list = json['sections'] as List<dynamic>? ?? const [];
    return PrivacyPolicyDocument(
      sections: list.map((e) => PrivacySection.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final List<PrivacySection> sections;

  static Future<PrivacyPolicyDocument> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PrivacyPolicyDocument.fromJson(map);
  }
}

@immutable
class PrivacySection {
  const PrivacySection({
    required this.id,
    required this.title,
    this.paragraphs = const [],
    this.subsections = const [],
    this.useCases = const [],
    this.securityBullets = const [],
    this.retentionCards = const [],
    this.rightsCards = const [],
    this.footer,
    this.contactTeam,
    this.contactEmail,
    this.contactPhone,
  });

  factory PrivacySection.fromJson(Map<String, dynamic> json) {
    return PrivacySection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      paragraphs: _stringList(json['paragraphs']),
      subsections: _subsections(json['subsections']),
      useCases: _useCases(json['useCases']),
      securityBullets: _stringList(json['securityBullets']),
      retentionCards: _titleBody(json['retentionCards']),
      rightsCards: _titleBody(json['rightsCards']),
      footer: json['footer'] as String?,
      contactTeam: json['contactTeam'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }

  final String id;
  final String title;
  final List<String> paragraphs;
  final List<PrivacySubsection> subsections;
  final List<PrivacyUseCase> useCases;
  final List<String> securityBullets;
  final List<PrivacyTitleBody> retentionCards;
  final List<PrivacyTitleBody> rightsCards;
  final String? footer;
  final String? contactTeam;
  final String? contactEmail;
  final String? contactPhone;

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => '$e').toList();
  }

  static List<PrivacySubsection> _subsections(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => PrivacySubsection.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<PrivacyUseCase> _useCases(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => PrivacyUseCase.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<PrivacyTitleBody> _titleBody(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => PrivacyTitleBody.fromJson(e as Map<String, dynamic>)).toList();
  }
}

@immutable
class PrivacySubsection {
  const PrivacySubsection({
    required this.title,
    this.intro,
    required this.accent,
    required this.bullets,
  });

  factory PrivacySubsection.fromJson(Map<String, dynamic> json) {
    final bl = json['bullets'] as List<dynamic>? ?? const [];
    return PrivacySubsection(
      title: json['title'] as String? ?? '',
      intro: json['intro'] as String?,
      accent: json['accent'] as String? ?? 'blue',
      bullets: bl.map((e) => PrivacyBullet.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String title;
  final String? intro;
  final String accent;
  final List<PrivacyBullet> bullets;
}

@immutable
class PrivacyBullet {
  const PrivacyBullet({required this.title, required this.purpose});

  factory PrivacyBullet.fromJson(Map<String, dynamic> json) {
    return PrivacyBullet(
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
    );
  }

  final String title;
  final String purpose;
}

@immutable
class PrivacyUseCase {
  const PrivacyUseCase({required this.title, required this.description});

  factory PrivacyUseCase.fromJson(Map<String, dynamic> json) {
    return PrivacyUseCase(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final String title;
  final String description;
}

@immutable
class PrivacyTitleBody {
  const PrivacyTitleBody({required this.title, required this.body});

  factory PrivacyTitleBody.fromJson(Map<String, dynamic> json) {
    return PrivacyTitleBody(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  final String title;
  final String body;
}
