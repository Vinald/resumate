import 'package:flutter/services.dart' show rootBundle;

import '../models/app_settings.dart';
import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';

/// Escapes LaTeX-special characters in free text.
String latexEscape(String input) {
  const map = {
    '\\': r'\textbackslash{}',
    '&': r'\&',
    '%': r'\%',
    r'$': r'\$',
    '#': r'\#',
    '_': r'\_',
    '{': r'\{',
    '}': r'\}',
    '~': r'\textasciitilde{}',
    '^': r'\textasciicircum{}',
  };
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch);
  }
  return buffer.toString();
}

/// Fills the bundled `.tex` templates with data from a [GeneratedDocument].
class LatexEngine {
  /// Test / non-Flutter callers can inject a loader.
  LatexEngine({Future<String> Function(String asset)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  final Future<String> Function(String asset) _loadAsset;

  Future<String> render(GeneratedDocument doc, AppSettings settings) async {
    if (doc.type == DocumentType.resume) {
      final template = await _loadAsset('assets/templates/resume_classic.tex');
      return renderResume(template, doc.resume!, settings);
    }
    final template = await _loadAsset(doc.type.letterKind.templateAsset);
    return renderLetter(template, doc.letter!, settings);
  }

  String renderResume(String template, ResumeData r, AppSettings settings) {
    final k = r.contact;
    final tokens = <String, String>{
      'ACCENT_RGB': settings.accentRgb,
      'NAME': latexEscape(k.name),
      'TITLE': latexEscape(k.title),
      'PORTFOLIO_URL': k.portfolioUrl,
      'PHONE': latexEscape(k.phone),
      'EMAIL': k.email,
      'GITHUB_URL': k.githubUrl,
      'GITHUB_LABEL': latexEscape(k.githubLabel.isEmpty ? 'GitHub' : k.githubLabel),
      'LINKEDIN_URL': k.linkedinUrl,
      'LINKEDIN_LABEL':
          latexEscape(k.linkedinLabel.isEmpty ? 'LinkedIn' : k.linkedinLabel),
      'SUMMARY': latexEscape(r.summary),
      'EXPERIENCE_ITEMS': _experienceItems(r.experience),
      'SKILLS_ITEMS': _skillItems(r.skills),
      'SOFT_SKILLS': r.softSkills.map(latexEscape).join(r' \hspace{10pt} '),
      'EDUCATION_ITEMS': _educationItems(r.education),
      'PROJECT_ITEMS': _projectItems(r.projects),
      'REFERENCES': _references(r),
    };
    return _apply(template, tokens);
  }

  String renderLetter(String template, LetterData l, AppSettings settings) {
    final k = l.contact;
    final body = l.body
        .map((p) => latexEscape(l.resolve(p)))
        .join('\n\n');
    final tokens = <String, String>{
      'ACCENT_RGB': settings.accentRgb,
      'NAME': latexEscape(k.name),
      'TITLE': latexEscape(k.title),
      'PORTFOLIO_URL': k.portfolioUrl,
      'PHONE': latexEscape(k.phone),
      'EMAIL': k.email,
      'GITHUB_URL': k.githubUrl,
      'GITHUB_LABEL': latexEscape(k.githubLabel.isEmpty ? 'GitHub' : k.githubLabel),
      'LINKEDIN_URL': k.linkedinUrl,
      'LINKEDIN_LABEL':
          latexEscape(k.linkedinLabel.isEmpty ? 'LinkedIn' : k.linkedinLabel),
      'DATE': l.date.trim().isEmpty ? r'\today' : latexEscape(l.date),
      'RECIPIENT_DEPT': latexEscape(l.recipientDept),
      'COMPANY_NAME': latexEscape(l.resolve(l.companyName)),
      'COMPANY_ADDRESS': latexEscape(l.resolve(l.companyAddress)),
      'SALUTATION': latexEscape(l.salutation),
      'BODY': body,
      'CLOSING': latexEscape(l.closing),
      'SIGNATURE_IMAGE':
          (settings.signatureImagePath != null &&
                  settings.signatureImagePath!.isNotEmpty)
              ? '% Upload your signature as signature.png alongside this file.\n'
                  r'\includegraphics[width=0.12\textwidth]{signature.png}'
              : '',
      'SIGNATURE_NAME': latexEscape(
        l.signatureName.isEmpty ? k.name : l.signatureName,
      ),
    };
    return _apply(template, tokens);
  }

  String _apply(String template, Map<String, String> tokens) {
    var out = template;
    tokens.forEach((key, value) {
      out = out.replaceAll('<<$key>>', value);
    });
    return out;
  }

  String _experienceItems(List<ExperienceEntry> entries) {
    final buffer = StringBuffer();
    for (final e in entries) {
      final heading =
          [e.role, e.organization].where((s) => s.isNotEmpty).map(latexEscape).join(', ');
      buffer.writeln(
        '\\textbf{$heading} \\hfill \\textbf{${latexEscape(e.dateRange)}}',
      );
      buffer.writeln('\\vspace{-7pt}');
      final bullets = e.bullets.where((b) => b.trim().isNotEmpty).toList();
      if (bullets.isNotEmpty) {
        buffer.writeln('\\begin{itemize}[label=\\tick]');
        for (final b in bullets) {
          buffer.writeln('    \\item ${latexEscape(b)} \\vspace{-5pt}');
        }
        buffer.writeln('\\end{itemize}');
      }
      buffer.writeln('\\vspace{-3pt}');
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  String _skillItems(List<SkillCategory> skills) {
    return skills
        .map(
          (s) =>
              '\\textbf{${latexEscape(s.label)}:} ${s.items.map(latexEscape).join(', ')} \\\\',
        )
        .join('\n');
  }

  String _educationItems(List<EducationEntry> education) {
    final buffer = StringBuffer();
    for (final ed in education) {
      final dates = ed.dates.isEmpty ? '' : ' \\hfill \\textbf{${latexEscape(ed.dates)}}';
      buffer.writeln('\\textbf{${latexEscape(ed.qualification)}}$dates \\\\');
      buffer.writeln('${latexEscape(ed.institution)} \\vspace{-5pt}');
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  String _projectItems(List<ProjectEntry> projects) {
    final buffer = StringBuffer();
    for (final p in projects) {
      final tech = p.tech.isEmpty ? '' : ' \\hfill \\textbf{${latexEscape(p.tech)}}';
      buffer.writeln('\\noindent \\textbf{${latexEscape(p.name)}}$tech \\\\');
      if (p.description.isNotEmpty) {
        buffer.writeln(latexEscape(p.description));
      }
      buffer.writeln('\\vspace{5pt}');
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  String _references(ResumeData r) {
    if (r.referencesOnRequest) {
      return '\\textit{${latexEscape(r.referencesNote)}}';
    }
    final buffer = StringBuffer();
    for (final ref in r.references) {
      buffer.writeln(
        '\\textbf{${latexEscape([ref.name, ref.organization].where((s) => s.isNotEmpty).join(' from '))}}\\\\',
      );
      buffer.writeln(
        '${latexEscape(ref.email)} ${latexEscape(ref.phone)}',
      );
      buffer.writeln('\\vspace{5pt}');
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }
}
