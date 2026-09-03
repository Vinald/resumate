import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_generator/data/seed_data.dart';
import 'package:resume_generator/latex/latex_engine.dart';
import 'package:resume_generator/models/app_settings.dart';
import 'package:resume_generator/models/document.dart';

Future<String> _loadFromDisk(String asset) => File(asset).readAsString();

void main() {
  final engine = LatexEngine(loadAsset: _loadFromDisk);
  final settings = AppSettings();

  test('latexEscape handles special characters', () {
    expect(latexEscape('50% & rising_fast'), r'50\% \& rising\_fast');
    expect(latexEscape(r'a$b#c'), r'a\$b\#c');
  });

  test('resume render fills every token', () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final tex = await engine.render(doc, settings);

    expect(tex, isNot(contains('<<')));
    expect(tex, contains('OKIROR SAMUEL VINALD'));
    expect(tex, contains(r'\definecolor{blue}{RGB}{0, 0, 255}'));
    expect(tex, contains(r'\begin{document}'));
    expect(tex, contains(r'\end{document}'));
    expect(tex, contains(r'\item')); // experience bullets
    expect(tex, contains('Infectious Diseases Institute'));
  });

  test('letter render resolves placeholders and fills tokens', () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.coverLetter,
    );
    doc.letter!.placeholders['position'] = 'Backend Engineer';
    doc.letter!.placeholders['company'] = 'Acme Ltd';

    final tex = await engine.render(doc, settings);
    expect(tex, isNot(contains('<<')));
    expect(tex, isNot(contains('{{')));
    expect(tex, contains('Backend Engineer'));
    expect(tex, contains('Acme Ltd'));
  });

  test('accent colour from settings flows into the RGB token', () async {
    final doc = SeedData.initialDocuments().first;
    final tex = await engine.render(
      doc,
      AppSettings(accentColor: 0xFF112233),
    );
    expect(tex, contains('{RGB}{17, 34, 51}'));
  });
}
