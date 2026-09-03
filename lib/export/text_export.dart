import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';

/// Plain-text and Markdown serialization for resumes and letters.
class TextExport {
  static String plain(GeneratedDocument doc) =>
      doc.type == DocumentType.resume
          ? _resume(doc.resume!, markdown: false)
          : _letter(doc.letter!, markdown: false);

  static String markdown(GeneratedDocument doc) =>
      doc.type == DocumentType.resume
          ? _resume(doc.resume!, markdown: true)
          : _letter(doc.letter!, markdown: true);

  static String _h(String text, bool markdown, {int level = 2}) =>
      markdown ? '${'#' * level} $text' : text.toUpperCase();

  static String _resume(ResumeData r, {required bool markdown}) {
    final b = StringBuffer();
    final k = r.contact;
    b.writeln(markdown ? '# ${k.name}' : k.name);
    if (k.title.isNotEmpty) b.writeln(k.title);
    final contact = [
      if (k.phone.isNotEmpty) k.phone,
      if (k.email.isNotEmpty) k.email,
      if (k.portfolioUrl.isNotEmpty) k.portfolioUrl,
      if (k.githubUrl.isNotEmpty) k.githubUrl,
      if (k.linkedinUrl.isNotEmpty) k.linkedinUrl,
    ].join(' | ');
    if (contact.isNotEmpty) b.writeln(contact);

    if (r.summary.trim().isNotEmpty) {
      b..writeln()..writeln(_h('Summary', markdown))..writeln(r.summary);
    }

    if (r.experience.isNotEmpty) {
      b..writeln()..writeln(_h('Employment History', markdown));
      for (final e in r.experience) {
        final head = [e.role, e.organization].where((s) => s.isNotEmpty).join(', ');
        b.writeln();
        b.writeln(
          markdown
              ? '### $head${e.dateRange.isNotEmpty ? '  _(${e.dateRange})_' : ''}'
              : '$head${e.dateRange.isNotEmpty ? '  (${e.dateRange})' : ''}',
        );
        for (final bullet in e.bullets.where((s) => s.trim().isNotEmpty)) {
          b.writeln('- $bullet');
        }
      }
    }

    if (r.skills.isNotEmpty) {
      b..writeln()..writeln(_h('Technical Skills', markdown));
      for (final s in r.skills) {
        b.writeln(
          markdown
              ? '- **${s.label}:** ${s.items.join(', ')}'
              : '${s.label}: ${s.items.join(', ')}',
        );
      }
    }

    if (r.softSkills.isNotEmpty) {
      b
        ..writeln()
        ..writeln(_h('Soft Skills', markdown))
        ..writeln(r.softSkills.join(', '));
    }

    if (r.education.isNotEmpty) {
      b..writeln()..writeln(_h('Education', markdown));
      for (final ed in r.education) {
        b.writeln();
        b.writeln(markdown ? '### ${ed.qualification}' : ed.qualification);
        if (ed.institution.isNotEmpty) b.writeln(ed.institution);
        if (ed.dates.isNotEmpty) b.writeln(ed.dates);
      }
    }

    if (r.projects.isNotEmpty) {
      b..writeln()..writeln(_h('Projects', markdown));
      for (final p in r.projects) {
        b.writeln();
        b.writeln(
          markdown
              ? '### ${p.name}${p.tech.isNotEmpty ? '  _(${p.tech})_' : ''}'
              : '${p.name}${p.tech.isNotEmpty ? '  (${p.tech})' : ''}',
        );
        if (p.description.isNotEmpty) b.writeln(p.description);
      }
    }

    b..writeln()..writeln(_h('References', markdown));
    if (r.referencesOnRequest) {
      b.writeln(r.referencesNote);
    } else {
      for (final ref in r.references) {
        b.writeln(
          '${[ref.name, ref.organization].where((s) => s.isNotEmpty).join(' — ')}'
          '${[ref.email, ref.phone].where((s) => s.isNotEmpty).join(', ').isNotEmpty ? '\n' : ''}'
          '${[ref.email, ref.phone].where((s) => s.isNotEmpty).join(', ')}',
        );
      }
    }

    return b.toString().trimRight();
  }

  static String _letter(LetterData l, {required bool markdown}) {
    final b = StringBuffer();
    final k = l.contact;
    b.writeln(markdown ? '# ${k.name}' : k.name);
    if (k.title.isNotEmpty) b.writeln(k.title);
    final contact = [
      if (k.phone.isNotEmpty) k.phone,
      if (k.email.isNotEmpty) k.email,
      if (k.portfolioUrl.isNotEmpty) k.portfolioUrl,
    ].join(' | ');
    if (contact.isNotEmpty) b.writeln(contact);
    b.writeln();
    b.writeln(l.date.trim().isEmpty ? '[Date]' : l.date);
    b.writeln();
    for (final line in [
      l.recipientDept,
      l.resolve(l.companyName),
      l.resolve(l.companyAddress),
    ].where((s) => s.trim().isNotEmpty)) {
      b.writeln(line);
    }
    b.writeln();
    b.writeln(l.salutation);
    b.writeln();
    for (final para in l.body) {
      b.writeln(l.resolve(para));
      b.writeln();
    }
    b.writeln(l.closing);
    b.writeln();
    b.writeln(l.signatureName.isEmpty ? k.name : l.signatureName);
    return b.toString().trimRight();
  }
}
