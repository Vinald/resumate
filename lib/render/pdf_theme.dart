import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/app_settings.dart';

/// Font Awesome glyph code points used on the contact line.
class FaGlyph {
  static final globe = String.fromCharCode(0xf0ac); // solid
  static final phone = String.fromCharCode(0xf095); // solid
  static final envelope = String.fromCharCode(0xf0e0); // solid
  static final github = String.fromCharCode(0xf09b); // brands
  static final linkedin = String.fromCharCode(0xf08c); // brands
  static final check = String.fromCharCode(0xf00c); // solid
}

/// Loads the bundled TTFs once and exposes a [pw.ThemeData] plus the
/// icon fonts, configured from [AppSettings].
class PdfTheme {
  PdfTheme._({
    required this.theme,
    required this.iconSolid,
    required this.iconBrands,
    required this.accent,
    required this.settings,
  });

  final pw.ThemeData theme;
  final pw.Font iconSolid;
  final pw.Font iconBrands;
  final PdfColor accent;
  final AppSettings settings;

  double get marginPt => settings.marginInches * 72.0;
  double get lineSpacing => settings.lineSpacing;

  static pw.Font? _regular;
  static pw.Font? _bold;
  static pw.Font? _italic;
  static pw.Font? _boldItalic;
  static pw.Font? _helv;
  static pw.Font? _helvBold;
  static pw.Font? _helvOblique;
  static pw.Font? _times;
  static pw.Font? _timesBold;
  static pw.Font? _timesItalic;
  static pw.Font? _iconSolid;
  static pw.Font? _iconBrands;

  static Future<pw.Font> _load(String asset) async =>
      pw.Font.ttf(await rootBundle.load(asset));

  static Future<PdfTheme> create(AppSettings settings) async {
    _iconSolid ??= await _load('assets/fonts/FontAwesome-Solid.ttf');
    _iconBrands ??= await _load('assets/fonts/FontAwesome-Brands.ttf');

    final pw.Font base, baseBold, baseItalic, baseBoldItalic;
    switch (settings.bodyFont) {
      case BodyFont.ebGaramond:
        _regular ??= await _load('assets/fonts/EBGaramond-Regular.ttf');
        _bold ??= await _load('assets/fonts/EBGaramond-Bold.ttf');
        _italic ??= await _load('assets/fonts/EBGaramond-Italic.ttf');
        _boldItalic ??= await _load('assets/fonts/EBGaramond-BoldItalic.ttf');
        base = _regular!;
        baseBold = _bold!;
        baseItalic = _italic!;
        baseBoldItalic = _boldItalic!;
      case BodyFont.helvetica:
        _helv ??= pw.Font.helvetica();
        _helvBold ??= pw.Font.helveticaBold();
        _helvOblique ??= pw.Font.helveticaOblique();
        base = _helv!;
        baseBold = _helvBold!;
        baseItalic = _helvOblique!;
        baseBoldItalic = _helvOblique!;
      case BodyFont.times:
        _times ??= pw.Font.times();
        _timesBold ??= pw.Font.timesBold();
        _timesItalic ??= pw.Font.timesItalic();
        base = _times!;
        baseBold = _timesBold!;
        baseItalic = _timesItalic!;
        baseBoldItalic = _timesItalic!;
    }

    final theme = pw.ThemeData.withFont(
      base: base,
      bold: baseBold,
      italic: baseItalic,
      boldItalic: baseBoldItalic,
      icons: _iconSolid,
      fontFallback: [_iconSolid!, _iconBrands!],
    ).copyWith(
      defaultTextStyle: pw.TextStyle(
        font: base,
        fontSize: 11,
        lineSpacing: (settings.lineSpacing - 1.0) * 11,
        color: PdfColors.black,
      ),
    );

    return PdfTheme._(
      theme: theme,
      iconSolid: _iconSolid!,
      iconBrands: _iconBrands!,
      accent: PdfColor.fromInt(settings.accentColor),
      settings: settings,
    );
  }
}
