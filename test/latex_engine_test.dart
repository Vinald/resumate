import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/data/seed_data.dart';
import 'package:resumate/latex/latex_engine.dart';
import 'package:resumate/models/app_settings.dart';
import 'package:resumate/models/document.dart';

Future<String> _loadFromDisk(String asset) => File(asset).readAsString();

void main() {
  final engine = LatexEngine(loadAsset: _loadFromDisk);
  final settings = AppSettings();

  test('latexEscape handles special characters', () {
    expect(latexEscape('50% & rising_fast'), r'50\% \& rising\_fast');
    expect(latexEscape(r'a$b#c'), r'a\$b\#c');
  });

  test('texUrl percent-encodes raw # and % without double-encoding', () {
    expect(texUrl('https://x.com/a#section'), 'https://x.com/a%23section');
    expect(texUrl('https://x.com/100% done'), 'https://x.com/100%25 done');
    expect(texUrl('https://x.com/a%20b'), 'https://x.com/a%20b');
    expect(texUrl('https://x.com/plain'), 'https://x.com/plain');
  });

  test('a # or % in a contact URL never reaches the .tex output raw',
      () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    doc.resume!.contact = doc.resume!.contact.copyWith(
      portfolioUrl: 'https://x.dev/cv#top',
      githubUrl: 'https://github.com/x?tab=repos%',
    );

    final tex = await engine.render(doc, settings);
    expect(tex, contains(r'\href{https://x.dev/cv%23top}'));
    expect(tex, contains(r'\href{https://github.com/x?tab=repos%25}'));
  });

  test('resume render fills every token', () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final tex = await engine.render(doc, settings);

    expect(tex, isNot(contains('<<')));
    expect(tex, contains('Alex Doe'));
    expect(tex, contains(r'\definecolor{blue}{RGB}{0, 0, 255}'));
    expect(tex, contains(r'\begin{document}'));
    expect(tex, contains(r'\end{document}'));
    expect(tex, contains(r'\item')); // experience bullets
    expect(tex, contains('Acme Corp'));
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

  test('signature image token emits includegraphics only when configured',
      () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.applicationLetter,
    );

    final without = await engine.render(doc, AppSettings());
    expect(without, isNot(contains(r'\includegraphics')));

    final withSig = await engine.render(
      doc,
      AppSettings(signatureImagePath: '/some/where/signature.png'),
    );
    expect(withSig, contains(r'\includegraphics[width=0.12\textwidth]{signature.png}'));
    expect(withSig, isNot(contains('<<')));
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
