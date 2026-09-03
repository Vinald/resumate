import 'contact_info.dart';

enum BodyFont {
  ebGaramond,
  helvetica,
  times;

  String get label => switch (this) {
    BodyFont.ebGaramond => 'EB Garamond (LaTeX-like)',
    BodyFont.helvetica => 'Helvetica',
    BodyFont.times => 'Times',
  };
}

/// User-wide preferences applied to every generated document.
class AppSettings {
  AppSettings({
    ContactInfo? defaultContact,
    this.signatureImagePath,
    this.accentColor = 0xFF0000FF,
    this.marginInches = 0.6,
    this.lineSpacing = 1.3,
    this.bodyFont = BodyFont.ebGaramond,
  }) : defaultContact = defaultContact ?? const ContactInfo();

  ContactInfo defaultContact;
  String? signatureImagePath;

  /// ARGB int. Defaults to pure blue (#0000FF) to match the LaTeX template.
  int accentColor;
  double marginInches;
  double lineSpacing;
  BodyFont bodyFont;

  /// The accent colour split into 0-255 R, G, B for `.tex` output.
  String get accentRgb {
    final r = (accentColor >> 16) & 0xFF;
    final g = (accentColor >> 8) & 0xFF;
    final b = accentColor & 0xFF;
    return '$r, $g, $b';
  }

  AppSettings copyWith({
    ContactInfo? defaultContact,
    String? signatureImagePath,
    bool clearSignature = false,
    int? accentColor,
    double? marginInches,
    double? lineSpacing,
    BodyFont? bodyFont,
  }) {
    return AppSettings(
      defaultContact: defaultContact ?? this.defaultContact,
      signatureImagePath:
          clearSignature ? null : (signatureImagePath ?? this.signatureImagePath),
      accentColor: accentColor ?? this.accentColor,
      marginInches: marginInches ?? this.marginInches,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      bodyFont: bodyFont ?? this.bodyFont,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultContact': defaultContact.toJson(),
    'signatureImagePath': signatureImagePath,
    'accentColor': accentColor,
    'marginInches': marginInches,
    'lineSpacing': lineSpacing,
    'bodyFont': bodyFont.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    defaultContact: ContactInfo.fromJson(
      (json['defaultContact'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    signatureImagePath: json['signatureImagePath'] as String?,
    accentColor: json['accentColor'] as int? ?? 0xFF0000FF,
    marginInches: (json['marginInches'] as num?)?.toDouble() ?? 0.6,
    lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.3,
    bodyFont: BodyFont.values.firstWhere(
      (f) => f.name == json['bodyFont'],
      orElse: () => BodyFont.ebGaramond,
    ),
  );
}
