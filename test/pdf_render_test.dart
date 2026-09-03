import 'package:flutter_test/flutter_test.dart';
import 'package:resume_generator/data/seed_data.dart';
import 'package:resume_generator/models/app_settings.dart';
import 'package:resume_generator/models/document.dart';
import 'package:resume_generator/render/document_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resume renders to a non-trivial PDF', () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.resume,
    );
    final bytes = await buildDocumentPdf(doc, AppSettings());
    expect(bytes.length, greaterThan(3000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('letter renders to a PDF with a custom accent colour', () async {
    final doc = SeedData.initialDocuments().firstWhere(
      (d) => d.type == DocumentType.applicationLetter,
    );
    final bytes = await buildDocumentPdf(
      doc,
      AppSettings(accentColor: 0xFF008080),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
