import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume.dart';
import 'pdf_components.dart';
import 'pdf_theme.dart';
import 'resume_template.dart';

/// Default resume template, styled after the Overleaf LaTeX source:
/// huge left-aligned name, accent title on the right, accent rules,
/// centred uppercase headings and `✓` bullets.
class ClassicBlueTemplate implements ResumeTemplate {
  @override
  String get id => 'classic_blue';

  @override
  String get name => 'Classic Blue';

  @override
  pw.Document build(
    ResumeData data,
    PdfTheme theme, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    final c = PdfComponents(theme);
    final doc = pw.Document();

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
          _header(data, c, theme),
          if (data.summary.trim().isNotEmpty) ...[
            c.sectionHeader('Summary'),
            pw.Text(data.summary, textAlign: pw.TextAlign.justify),
          ],
          if (data.experience.isNotEmpty) ...[
            c.sectionHeader('Employment History'),
            for (final e in data.experience) _experience(e, c),
          ],
          if (data.skills.isNotEmpty) ...[
            c.sectionHeader('Technical Skills'),
            for (final s in data.skills)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${s.label}: ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: s.items.join(', ')),
                    ],
                  ),
                ),
              ),
          ],
          if (data.softSkills.isNotEmpty) ...[
            c.sectionHeader('Soft Skills'),
            pw.Text(data.softSkills.join('      ')),
          ],
          if (data.education.isNotEmpty) ...[
            c.sectionHeader('Education'),
            for (final ed in data.education) _education(ed),
          ],
          if (data.projects.isNotEmpty) ...[
            c.sectionHeader('Projects'),
            for (final p in data.projects) _project(p),
          ],
          ..._references(data, c),
        ],
      ),
    );
    return doc;
  }

  pw.Widget _header(ResumeData data, PdfComponents c, PdfTheme theme) {
    final k = data.contact;
    final contactBits = <pw.Widget>[
      if (k.portfolioUrl.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.globe, c.link('Portfolio', k.portfolioUrl)),
      if (k.phone.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.phone, pw.Text(k.phone)),
      if (k.email.isNotEmpty)
        c.iconText(theme.iconSolid, FaGlyph.envelope, c.link(k.email, 'mailto:${k.email}')),
      if (k.githubUrl.isNotEmpty || k.githubLabel.isNotEmpty)
        c.iconText(theme.iconBrands, FaGlyph.github,
            c.link(k.githubLabel.isEmpty ? 'GitHub' : k.githubLabel, k.githubUrl)),
      if (k.linkedinUrl.isNotEmpty || k.linkedinLabel.isNotEmpty)
        c.iconText(theme.iconBrands, FaGlyph.linkedin,
            c.link(k.linkedinLabel.isEmpty ? 'LinkedIn' : k.linkedinLabel, k.linkedinUrl)),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 63,
              child: pw.Text(
                k.name,
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Expanded(
              flex: 37,
              child: pw.Text(
                k.title.toUpperCase(),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: c.accent,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 1, color: c.accent),
        pw.SizedBox(height: 6),
        pw.Wrap(spacing: 12, runSpacing: 3, children: contactBits),
      ],
    );
  }

  pw.Widget _experience(ExperienceEntry e, PdfComponents c) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                [e.role, e.organization].where((s) => s.isNotEmpty).join(', '),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (e.dateRange.isNotEmpty)
              pw.Text(
                e.dateRange,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
          ],
        ),
        pw.SizedBox(height: 2),
        for (final b in e.bullets)
          if (b.trim().isNotEmpty) c.tickBullet(b),
        pw.SizedBox(height: 2),
      ],
    );
  }

  pw.Widget _education(EducationEntry ed) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  ed.qualification,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (ed.dates.isNotEmpty)
                pw.Text(
                  ed.dates,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
          if (ed.institution.isNotEmpty) pw.Text(ed.institution),
        ],
      ),
    );
  }

  pw.Widget _project(ProjectEntry p) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  p.name,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              if (p.tech.isNotEmpty)
                pw.Text(
                  p.tech,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
          if (p.description.isNotEmpty)
            pw.Text(p.description, textAlign: pw.TextAlign.justify),
        ],
      ),
    );
  }

  List<pw.Widget> _references(ResumeData data, PdfComponents c) {
    if (data.referencesOnRequest) {
      if (data.referencesNote.trim().isEmpty) return const [];
      return [
        c.sectionHeader('References'),
        pw.Text(data.referencesNote, style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      ];
    }
    if (data.references.isEmpty) return const [];
    return [
      c.sectionHeader('References'),
      for (final r in data.references)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                [r.name, r.organization].where((s) => s.isNotEmpty).join(' — '),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text([r.email, r.phone].where((s) => s.isNotEmpty).join('   ')),
            ],
          ),
        ),
    ];
  }
}
