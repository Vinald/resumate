import 'contact_info.dart';

enum LetterKind {
  cover,
  application;

  String get label =>
      this == LetterKind.cover ? 'Cover letter' : 'Application letter';

  String get templateAsset =>
      this == LetterKind.cover
          ? 'assets/templates/cover_letter.tex'
          : 'assets/templates/application_letter.tex';
}

/// The content of a cover or application letter.
///
/// Body paragraphs may contain `{{placeholder}}` tokens (e.g. `{{position}}`,
/// `{{company}}`) which are resolved from [placeholders] before rendering.
class LetterData {
  LetterData({
    ContactInfo? contact,
    this.kind = LetterKind.cover,
    this.date = '',
    this.recipientDept = 'Human Resources Department',
    this.companyName = '{{company}}',
    this.companyAddress = 'City, Country',
    this.salutation = 'Dear Hiring Manager,',
    List<String>? body,
    this.closing = 'Sincerely,',
    this.signatureName = '',
    Map<String, String>? placeholders,
  }) : contact = contact ?? const ContactInfo(),
       body = body ?? <String>[],
       placeholders = placeholders ?? <String, String>{};

  ContactInfo contact;
  LetterKind kind;
  String date;
  String recipientDept;
  String companyName;
  String companyAddress;
  String salutation;
  List<String> body;
  String closing;
  String signatureName;
  Map<String, String> placeholders;

  /// Distinct `{{token}}` names appearing anywhere in the letter text.
  Set<String> get placeholderNames {
    final re = RegExp(r'\{\{\s*([a-zA-Z0-9_ ]+?)\s*\}\}');
    final names = <String>{};
    for (final text in [
      companyName,
      companyAddress,
      salutation,
      recipientDept,
      ...body,
    ]) {
      for (final m in re.allMatches(text)) {
        names.add(m.group(1)!.trim());
      }
    }
    return names;
  }

  String resolve(String text) {
    return text.replaceAllMapped(
      RegExp(r'\{\{\s*([a-zA-Z0-9_ ]+?)\s*\}\}'),
      (m) {
        final key = m.group(1)!.trim();
        final value = placeholders[key];
        return (value == null || value.isEmpty) ? '[$key]' : value;
      },
    );
  }

  LetterData copy() => LetterData(
    contact: contact.copyWith(),
    kind: kind,
    date: date,
    recipientDept: recipientDept,
    companyName: companyName,
    companyAddress: companyAddress,
    salutation: salutation,
    body: List<String>.from(body),
    closing: closing,
    signatureName: signatureName,
    placeholders: Map<String, String>.from(placeholders),
  );

  Map<String, dynamic> toJson() => {
    'contact': contact.toJson(),
    'kind': kind.name,
    'date': date,
    'recipientDept': recipientDept,
    'companyName': companyName,
    'companyAddress': companyAddress,
    'salutation': salutation,
    'body': body,
    'closing': closing,
    'signatureName': signatureName,
    'placeholders': placeholders,
  };

  factory LetterData.fromJson(Map<String, dynamic> json) => LetterData(
    contact: ContactInfo.fromJson(
      (json['contact'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    kind: LetterKind.values.firstWhere(
      (k) => k.name == json['kind'],
      orElse: () => LetterKind.cover,
    ),
    date: json['date'] as String? ?? '',
    recipientDept: json['recipientDept'] as String? ?? 'Human Resources Department',
    companyName: json['companyName'] as String? ?? '{{company}}',
    companyAddress: json['companyAddress'] as String? ?? 'City, Country',
    salutation: json['salutation'] as String? ?? 'Dear Hiring Manager,',
    body:
        (json['body'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
    closing: json['closing'] as String? ?? 'Sincerely,',
    signatureName: json['signatureName'] as String? ?? '',
    placeholders:
        (json['placeholders'] as Map?)?.map(
          (k, v) => MapEntry(k as String, v as String),
        ) ??
        <String, String>{},
  );
}
