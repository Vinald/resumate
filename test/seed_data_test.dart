import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumate/data/seed_data.dart';
import 'package:resumate/models/document.dart';

void main() {
  test('seed documents cover resume + both letter types', () {
    final docs = SeedData.initialDocuments();
    expect(docs.map((d) => d.type).toSet(), {
      DocumentType.resume,
      DocumentType.coverLetter,
      DocumentType.applicationLetter,
    });
  });

  test('seed resume has the expected shape', () {
    final resume = SeedData.resume();
    expect(resume.contact.name, 'Alex Doe');
    expect(resume.experience.length, 5);
    expect(resume.skills.length, 8);
    expect(resume.education.length, 3);
    expect(resume.projects.length, 3);
    expect(resume.summary, contains('Full-stack software engineer'));
  });

  test('every seed document survives a JSON round-trip', () {
    for (final doc in SeedData.initialDocuments()) {
      final restored = GeneratedDocument.fromJson(
        jsonDecode(jsonEncode(doc.toJson())) as Map<String, dynamic>,
      );
      expect(restored.title, doc.title);
      expect(restored.type, doc.type);
      if (doc.type == DocumentType.resume) {
        expect(restored.resume!.experience.length,
            doc.resume!.experience.length);
      } else {
        expect(restored.letter!.body.length, doc.letter!.body.length);
      }
    }
  });

  test('seed letters expose position + company placeholders', () {
    expect(SeedData.coverLetter().placeholderNames, contains('position'));
    expect(SeedData.coverLetter().placeholderNames, contains('company'));
    expect(SeedData.applicationLetter().placeholderNames, contains('company'));
  });
}
