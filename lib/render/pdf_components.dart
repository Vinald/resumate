import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_theme.dart';

/// Shared building blocks for the Classic Blue templates.
class PdfComponents {
  PdfComponents(this.theme);

  final PdfTheme theme;

  PdfColor get accent => theme.accent;

  /// Centred uppercase accent heading followed by a full-width accent rule.
  pw.Widget sectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              color: accent,
              fontWeight: pw.FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 1, color: accent),
        pw.SizedBox(height: 6),
      ],
    );
  }

  /// A `✓`-led bullet.
  pw.Widget tickBullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2, left: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 12,
            child: pw.Text(
              FaGlyph.check,
              style: pw.TextStyle(font: theme.iconSolid, fontSize: 8, color: accent),
            ),
          ),
          pw.Expanded(child: pw.Text(text, textAlign: pw.TextAlign.left)),
        ],
      ),
    );
  }

  pw.Widget iconText(pw.Font font, String glyph, pw.Widget child) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(glyph, style: pw.TextStyle(font: font, fontSize: 8.5, color: accent)),
        pw.SizedBox(width: 3),
        child,
      ],
    );
  }

  pw.Widget link(String text, String url) {
    if (url.trim().isEmpty) return pw.Text(text);
    return pw.UrlLink(
      destination: url,
      child: pw.Text(
        text,
        style: const pw.TextStyle(color: PdfColors.black),
      ),
    );
  }
}
