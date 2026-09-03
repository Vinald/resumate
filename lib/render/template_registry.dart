import 'classic_blue_template.dart';
import 'classic_letter_template.dart';
import 'letter_template.dart';
import 'resume_template.dart';

/// Lookup for the available templates. Add new templates here.
class TemplateRegistry {
  static final List<ResumeTemplate> resumeTemplates = [ClassicBlueTemplate()];
  static final List<LetterTemplate> letterTemplates = [ClassicLetterTemplate()];

  static ResumeTemplate resume(String id) => resumeTemplates.firstWhere(
    (t) => t.id == id,
    orElse: () => resumeTemplates.first,
  );

  static LetterTemplate letter(String id) => letterTemplates.firstWhere(
    (t) => t.id == id,
    orElse: () => letterTemplates.first,
  );
}
