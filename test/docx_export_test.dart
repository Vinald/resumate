import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resume_generator/data/seed_data.dart';
import 'package:resume_generator/export/docx_export.dart';
import 'package:resume_generator/models/document.dart';

void main() {
  Archive unzip(List<int> bytes) => ZipDecoder().decodeBytes(bytes);

  test('resume docx is a valid zip with the required parts', () {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final bytes = DocxExport.build(doc);
    expect(bytes.length, greaterThan(500));

    final archive = unzip(bytes);
    final names = archive.files.map((f) => f.name).toSet();
    expect(names, containsAll(<String>[
      '[Content_Types].xml',
      '_rels/.rels',
      'word/document.xml',
      'word/styles.xml',
    ]));

    final documentXml = utf8.decode(
      archive.findFile('word/document.xml')!.content as List<int>,
    );
    expect(documentXml, contains('<w:document'));
    expect(documentXml, contains('OKIROR SAMUEL VINALD'));
    expect(documentXml, contains('Employment History'.toUpperCase()));
  });

  test('letter docx resolves placeholders and escapes XML', () {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.coverLetter,
    );
    doc.letter!.placeholders['company'] = 'Tom & Jerry <Inc>';
    final archive = unzip(DocxExport.build(doc));
    final xml = utf8.decode(
      archive.findFile('word/document.xml')!.content as List<int>,
    );
    expect(xml, contains('Tom &amp; Jerry &lt;Inc&gt;'));
    expect(xml, isNot(contains('{{company}}')));
  });
}
