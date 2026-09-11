import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/letter.dart';
import 'letter_template.dart';
import 'pdf_components.dart';
import 'pdf_theme.dart';

/// Default letter template (cover + application), matching the LaTeX source:
/// centred name/title header, accent rule, dated block, justified body,
/// signature image + typed name.
class ClassicLetterTemplate implements LetterTemplate {
  @override
  String get id => 'classic_letter';

  @override
  String get name => 'Classic Letter';

  @override
  pw.Document build(
    LetterData data,
    PdfTheme theme, {
    List<int>? signature,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    final c = PdfComponents(theme);
    final doc = pw.Document();
    final k = data.contact;
    final date =
        data.date.trim().isNotEmpty
            ? data.date.trim()
            : DateFormat('d MMMM y').format(DateTime.now());

    final contactBits = <pw.Widget>[
      if (k.portfolioUrl.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.globe, c.link('Portfolio', k.portfolioUrl)),
      if (k.phone.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.phone, pw.Text(k.phone)),
      if (k.email.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.envelope, c.link(k.email, 'mailto:${k.email}')),
      if (k.githubLabel.isNotEmpty || k.githubUrl.isNotEmpty)
        c.iconText(theme.iconBrands, FaGlyph.github,
            c.link(k.githubLabel.isEmpty ? 'GitHub' : k.githubLabel, k.githubUrl)),
      if (k.linkedinLabel.isNotEmpty || k.linkedinUrl.isNotEmpty)
        c.iconText(theme.iconBrands, FaGlyph.linkedin,
            c.link(k.linkedinLabel.isEmpty ? 'LinkedIn' : k.linkedinLabel, k.linkedinUrl)),
    ];

    final recipientLines = [
      data.recipientDept,
      data.resolve(data.companyName),
      data.resolve(data.companyAddress),
    ].where((s) => s.trim().isNotEmpty);

    doc.addPage(
      pw.MultiPage(
        theme: theme.theme,
        pageFormat: pageFormat.copyWith(
          marginTop: theme.marginPt,
          marginBottom: theme.marginPt,
          marginLeft: theme.marginPt,
          marginRight: theme.marginPt,
        ),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  k.name,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  k.title.toUpperCase(),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  alignment: pw.WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 3,
                  children: contactBits,
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          ),
          pw.Container(height: 1, color: c.accent),
          pw.SizedBox(height: 14),
          pw.Text(date),
          pw.SizedBox(height: 10),
          for (final line in recipientLines) pw.Text(line),
          pw.SizedBox(height: 14),
          pw.Text(data.salutation),
          pw.SizedBox(height: 10),
          for (final para in data.body)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                data.resolve(para),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          pw.SizedBox(height: 6),
          pw.Text(data.closing),
          pw.SizedBox(height: 6),
          ?_buildSignatureImage(signature),
          pw.SizedBox(height: 4),
          pw.Text(
            data.signatureName.isEmpty ? k.name : data.signatureName,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    return doc;
  }

  /// Guards against a corrupt/mis-encoded signature file (e.g. one saved by
  /// an older build, before `SignaturePicker` started re-encoding to PNG on
  /// pick): `pw.MemoryImage` decodes eagerly and throws on bad bytes, which
  /// would otherwise take down the whole letter PDF.
  pw.Widget? _buildSignatureImage(List<int>? bytes) {
    if (bytes == null) return null;
    try {
      return pw.Image(
        pw.MemoryImage(Uint8List.fromList(bytes)),
        height: 44,
        alignment: pw.Alignment.centerLeft,
      );
    } catch (_) {
      return null;
    }
  }
}
