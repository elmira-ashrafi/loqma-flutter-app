import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class TermsOfServiceDocument {
  const TermsOfServiceDocument({required this.sections});

  factory TermsOfServiceDocument.fromJson(Map<String, dynamic> json) {
    final list = json['sections'] as List<dynamic>? ?? const [];
    return TermsOfServiceDocument(
      sections: list.map((e) => TermsSection.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final List<TermsSection> sections;

  static Future<TermsOfServiceDocument> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return TermsOfServiceDocument.fromJson(map);
  }
}

@immutable
class TermsSection {
  const TermsSection({
    required this.id,
    this.title,
    this.navTitle,
    this.callout,
    this.lead,
    this.blocks = const [],
    this.prohibited = const [],
    this.contactTeam,
    this.contactEmail,
    this.contactPhone,
    this.closingNote,
  });

  factory TermsSection.fromJson(Map<String, dynamic> json) {
    return TermsSection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String?,
      navTitle: json['navTitle'] as String?,
      callout: json['callout'] != null ? TermsCallout.fromJson(json['callout'] as Map<String, dynamic>) : null,
      lead: json['lead'] as String?,
      blocks: _blocks(json['blocks']),
      prohibited: _prohibited(json['prohibited']),
      contactTeam: json['contactTeam'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      closingNote: json['closingNote'] as String?,
    );
  }

  final String id;
  final String? title;
  final String? navTitle;
  final TermsCallout? callout;
  final String? lead;
  final List<TermsBlock> blocks;
  final List<TermsProhibitedItem> prohibited;
  final String? contactTeam;
  final String? contactEmail;
  final String? contactPhone;
  final String? closingNote;

  String get effectiveNavTitle => (navTitle != null && navTitle!.isNotEmpty)
      ? navTitle!
      : ((title != null && title!.isNotEmpty) ? title! : id);

  static List<TermsBlock> _blocks(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => TermsBlock.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<TermsProhibitedItem> _prohibited(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => TermsProhibitedItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

@immutable
class TermsCallout {
  const TermsCallout({
    required this.accent,
    this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });

  factory TermsCallout.fromJson(Map<String, dynamic> json) {
    return TermsCallout(
      accent: json['accent'] as String? ?? 'blue',
      title: json['title'] as String?,
      paragraphs: _stringList(json['paragraphs']),
      bullets: _stringList(json['bullets']),
    );
  }

  final String accent;
  final String? title;
  final List<String> paragraphs;
  final List<String> bullets;
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.map((e) => '$e').toList();
}

@immutable
class TermsBlock {
  const TermsBlock({
    this.heading,
    this.paragraph,
    this.paragraphs = const [],
    this.bullets = const [],
    this.orderedList = const [],
    this.callout,
  });

  factory TermsBlock.fromJson(Map<String, dynamic> json) {
    return TermsBlock(
      heading: json['heading'] as String?,
      paragraph: json['paragraph'] as String?,
      paragraphs: _stringList(json['paragraphs']),
      bullets: _stringList(json['bullets']),
      orderedList: _stringList(json['orderedList']),
      callout: json['callout'] != null ? TermsCallout.fromJson(json['callout'] as Map<String, dynamic>) : null,
    );
  }

  final String? heading;
  final String? paragraph;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<String> orderedList;
  final TermsCallout? callout;
}

@immutable
class TermsProhibitedItem {
  const TermsProhibitedItem({required this.title, required this.body});

  factory TermsProhibitedItem.fromJson(Map<String, dynamic> json) {
    return TermsProhibitedItem(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  final String title;
  final String body;
}
