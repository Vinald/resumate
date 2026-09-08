import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resume_generator/models/app_settings.dart';
import 'package:resume_generator/models/document.dart';
import 'package:resume_generator/models/letter.dart';
import 'package:resume_generator/models/resume.dart';

void main() {
  test('ResumeData survives a JSON round-trip', () {
    final resume = ResumeData(
      summary: 'Hello',
      experience: [
        ExperienceEntry(
          role: 'Dev',
          organization: 'Acme',
          startDate: '2024',
          endDate: 'Present',
          bullets: ['Did a thing', 'Did another'],
        ),
      ],
      skills: [
        SkillCategory(label: 'Languages', items: ['Dart', 'Kotlin']),
      ],
      softSkills: ['Teamwork'],
      education: [
        EducationEntry(qualification: 'BSc', institution: 'Example University'),
      ],
      projects: [ProjectEntry(name: 'P', tech: 'T', description: 'D')],
      references: [ReferenceEntry(name: 'Ref', email: 'r@x.com')],
    );

    final restored = ResumeData.fromJson(
      jsonDecode(jsonEncode(resume.toJson())) as Map<String, dynamic>,
    );

    expect(restored.summary, 'Hello');
    expect(restored.experience.single.bullets, ['Did a thing', 'Did another']);
    expect(restored.skills.single.items, ['Dart', 'Kotlin']);
    expect(restored.education.single.institution, 'Example University');
    expect(restored.projects.single.name, 'P');
    expect(restored.references.single.email, 'r@x.com');
  });

  test('LetterData round-trips and reports its placeholders', () {
    final letter = LetterData(
      kind: LetterKind.application,
      body: ['Apply for {{position}} at {{company}}.'],
      placeholders: {'position': 'Engineer', 'company': 'Acme'},
    );

    expect(letter.placeholderNames, {'position', 'company'});
    expect(
      letter.resolve(letter.body.first),
      'Apply for Engineer at Acme.',
    );

    final restored = LetterData.fromJson(
      jsonDecode(jsonEncode(letter.toJson())) as Map<String, dynamic>,
    );
    expect(restored.kind, LetterKind.application);
    expect(restored.placeholders['company'], 'Acme');
  });

  test('unresolved placeholders fall back to [name]', () {
    final letter = LetterData(body: ['Hi {{company}}']);
    expect(letter.resolve(letter.body.first), 'Hi [company]');
  });

  test('GeneratedDocument round-trips with its payload', () {
    final doc = GeneratedDocument(
      id: 'abc',
      type: DocumentType.resume,
      title: 'My Resume',
      updatedAt: DateTime.parse('2026-01-01T00:00:00.000'),
      resume: ResumeData(summary: 'x'),
    );
    final restored = GeneratedDocument.fromJson(
      jsonDecode(jsonEncode(doc.toJson())) as Map<String, dynamic>,
    );
    expect(restored.id, 'abc');
    expect(restored.type, DocumentType.resume);
    expect(restored.resume?.summary, 'x');
    expect(restored.letter, isNull);
  });

  test('AppSettings round-trips and derives accent RGB', () {
    final settings = AppSettings(accentColor: 0xFF0000FF);
    expect(settings.accentRgb, '0, 0, 255');
    final restored = AppSettings.fromJson(
      jsonDecode(jsonEncode(settings.toJson())) as Map<String, dynamic>,
    );
    expect(restored.accentColor, 0xFF0000FF);
    expect(restored.bodyFont, BodyFont.ebGaramond);
  });
}
