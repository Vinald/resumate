import 'package:flutter_test/flutter_test.dart';
import 'package:resume_generator/data/seed_data.dart';
import 'package:resume_generator/export/text_export.dart';
import 'package:resume_generator/models/document.dart';

void main() {
  test('plain resume text has section headers and bullets', () {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final text = TextExport.plain(doc);
    expect(text, contains('EMPLOYMENT HISTORY'));
    expect(text, contains('- Led development of'));
    expect(text, isNot(contains('#')));
  });

  test('markdown resume uses heading syntax', () {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final md = TextExport.markdown(doc);
    expect(md, contains('## Employment History'));
    expect(md, contains('# Alex Doe'));
  });

  test('letter text resolves placeholders', () {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.applicationLetter,
    );
    doc.letter!.placeholders['position'] = 'DevOps Engineer';
    doc.letter!.placeholders['company'] = 'Globex';
    final text = TextExport.plain(doc);
    expect(text, contains('DevOps Engineer'));
    expect(text, contains('Globex'));
    expect(text, isNot(contains('{{')));
  });
}
