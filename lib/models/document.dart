import 'letter.dart';
import 'resume.dart';

enum DocumentType {
  resume,
  coverLetter,
  applicationLetter;

  bool get isLetter => this != DocumentType.resume;

  String get label => switch (this) {
    DocumentType.resume => 'Resume',
    DocumentType.coverLetter => 'Cover letter',
    DocumentType.applicationLetter => 'Application letter',
  };

  LetterKind get letterKind =>
      this == DocumentType.applicationLetter
          ? LetterKind.application
          : LetterKind.cover;
}

/// A stored document: metadata plus exactly one of [resume] / [letter].
class GeneratedDocument {
  GeneratedDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.updatedAt,
    this.templateId = 'classic_blue',
    this.resume,
    this.letter,
  });

  final String id;
  DocumentType type;
  String title;
  DateTime updatedAt;
  String templateId;
  ResumeData? resume;
  LetterData? letter;

  GeneratedDocument touch() {
    updatedAt = DateTime.now();
    return this;
  }

  GeneratedDocument copyWith({
    String? id,
    DocumentType? type,
    String? title,
    DateTime? updatedAt,
    String? templateId,
    ResumeData? resume,
    LetterData? letter,
  }) {
    return GeneratedDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      templateId: templateId ?? this.templateId,
      resume: resume ?? this.resume?.copy(),
      letter: letter ?? this.letter?.copy(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
    'templateId': templateId,
    if (resume != null) 'resume': resume!.toJson(),
    if (letter != null) 'letter': letter!.toJson(),
  };

  factory GeneratedDocument.fromJson(Map<String, dynamic> json) {
    return GeneratedDocument(
      id: json['id'] as String,
      type: DocumentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DocumentType.resume,
      ),
      title: json['title'] as String? ?? 'Untitled',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      templateId: json['templateId'] as String? ?? 'classic_blue',
      resume:
          json['resume'] == null
              ? null
              : ResumeData.fromJson(
                (json['resume'] as Map).cast<String, dynamic>(),
              ),
      letter:
          json['letter'] == null
              ? null
              : LetterData.fromJson(
                (json['letter'] as Map).cast<String, dynamic>(),
              ),
    );
  }
}
