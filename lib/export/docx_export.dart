import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';

/// Builds a minimal but valid `.docx` (WordprocessingML) from a document.
///
/// The layout is deliberately simple — headings, bold runs and bullet lists —
/// so the result opens cleanly and stays editable in Word. It is not a pixel
/// match for the PDF.
class DocxExport {
  static Uint8List build(GeneratedDocument doc) {
    final body =
        doc.type == DocumentType.resume
            ? _resumeBody(doc.resume!)
            : _letterBody(doc.letter!);

    final documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:body>
$body
<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>
</w:body>
</w:document>''';

    final archive = Archive();
    void add(String name, String content) {
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile(name, bytes.length, bytes));
    }

    add('[Content_Types].xml', _contentTypes);
    add('_rels/.rels', _rootRels);
    add('word/_rels/document.xml.rels', _documentRels);
    add('word/styles.xml', _styles);
    add('word/document.xml', documentXml);

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  // --- Body builders -------------------------------------------------------

  static String _resumeBody(ResumeData r) {
    final b = StringBuffer();
    final k = r.contact;
    b.write(_para(k.name, bold: true, size: 32));
    if (k.title.isNotEmpty) b.write(_para(k.title.toUpperCase(), bold: true, size: 22));
    final contact = [
      if (k.phone.isNotEmpty) k.phone,
      if (k.email.isNotEmpty) k.email,
      if (k.portfolioUrl.isNotEmpty) k.portfolioUrl,
      if (k.githubUrl.isNotEmpty) k.githubUrl,
      if (k.linkedinUrl.isNotEmpty) k.linkedinUrl,
    ].join('  |  ');
    if (contact.isNotEmpty) b.write(_para(contact, size: 18));

    if (r.summary.trim().isNotEmpty) {
      b.write(_heading('Summary'));
      b.write(_para(r.summary));
    }

    if (r.experience.isNotEmpty) {
      b.write(_heading('Employment History'));
      for (final e in r.experience) {
        final head = [e.role, e.organization].where((s) => s.isNotEmpty).join(', ');
        b.write(_para(
          '$head${e.dateRange.isNotEmpty ? '  —  ${e.dateRange}' : ''}',
          bold: true,
        ));
        for (final bl in e.bullets.where((s) => s.trim().isNotEmpty)) {
          b.write(_bullet(bl));
        }
      }
    }

    if (r.skills.isNotEmpty) {
      b.write(_heading('Technical Skills'));
      for (final s in r.skills) {
        b.write(_labelValue(s.label, s.items.join(', ')));
      }
    }

    if (r.softSkills.isNotEmpty) {
      b.write(_heading('Soft Skills'));
      b.write(_para(r.softSkills.join(', ')));
    }

    if (r.education.isNotEmpty) {
      b.write(_heading('Education'));
      for (final ed in r.education) {
        b.write(_para(ed.qualification, bold: true));
        if (ed.institution.isNotEmpty) b.write(_para(ed.institution));
        if (ed.dates.isNotEmpty) b.write(_para(ed.dates));
      }
    }

    if (r.projects.isNotEmpty) {
      b.write(_heading('Projects'));
      for (final p in r.projects) {
        b.write(_para(
          '${p.name}${p.tech.isNotEmpty ? '  —  ${p.tech}' : ''}',
          bold: true,
        ));
        if (p.description.isNotEmpty) b.write(_para(p.description));
      }
    }

    b.write(_heading('References'));
    if (r.referencesOnRequest) {
      b.write(_para(r.referencesNote, italic: true));
    } else {
      for (final ref in r.references) {
        b.write(_para(
          [ref.name, ref.organization].where((s) => s.isNotEmpty).join(' — '),
          bold: true,
        ));
        final line = [ref.email, ref.phone].where((s) => s.isNotEmpty).join('   ');
        if (line.isNotEmpty) b.write(_para(line));
      }
    }

    return b.toString();
  }

  static String _letterBody(LetterData l) {
    final b = StringBuffer();
    final k = l.contact;
    b.write(_para(k.name, bold: true, size: 28, align: 'center'));
    if (k.title.isNotEmpty) {
      b.write(_para(k.title.toUpperCase(), bold: true, align: 'center'));
    }
    final contact = [
      if (k.phone.isNotEmpty) k.phone,
      if (k.email.isNotEmpty) k.email,
      if (k.portfolioUrl.isNotEmpty) k.portfolioUrl,
    ].join('  |  ');
    if (contact.isNotEmpty) b.write(_para(contact, size: 18, align: 'center'));
    b.write(_para(''));
    b.write(_para(l.date.trim().isEmpty ? '[Date]' : l.date));
    b.write(_para(''));
    for (final line in [
      l.recipientDept,
      l.resolve(l.companyName),
      l.resolve(l.companyAddress),
    ].where((s) => s.trim().isNotEmpty)) {
      b.write(_para(line));
    }
    b.write(_para(''));
    b.write(_para(l.salutation));
    b.write(_para(''));
    for (final para in l.body) {
      b.write(_para(l.resolve(para)));
      b.write(_para(''));
    }
    b.write(_para(l.closing));
    b.write(_para(''));
    b.write(_para(l.signatureName.isEmpty ? k.name : l.signatureName, bold: true));
    return b.toString();
  }

  // --- WordprocessingML fragments ----------------------------------------

  static String _heading(String text) =>
      '<w:p><w:pPr><w:pStyle w:val="Heading2"/><w:spacing w:before="240" w:after="60"/>'
      '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="0000FF"/></w:pBdr></w:pPr>'
      '<w:r><w:rPr><w:b/><w:color w:val="0000FF"/></w:rPr><w:t xml:space="preserve">${_x(text.toUpperCase())}</w:t></w:r></w:p>';

  static String _para(
    String text, {
    bool bold = false,
    bool italic = false,
    int? size,
    String? align,
  }) {
    final rPr = StringBuffer('<w:rPr>');
    if (bold) rPr.write('<w:b/>');
    if (italic) rPr.write('<w:i/>');
    if (size != null) rPr.write('<w:sz w:val="$size"/>');
    rPr.write('</w:rPr>');
    final pPr = align == null ? '' : '<w:pPr><w:jc w:val="$align"/></w:pPr>';
    return '<w:p>$pPr<w:r>$rPr<w:t xml:space="preserve">${_x(text)}</w:t></w:r></w:p>';
  }

  static String _bullet(String text) =>
      '<w:p><w:pPr><w:ind w:left="360" w:hanging="360"/></w:pPr>'
      '<w:r><w:t xml:space="preserve">${_x('✓  $text')}</w:t></w:r></w:p>';

  static String _labelValue(String label, String value) =>
      '<w:p><w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">${_x('$label: ')}</w:t></w:r>'
      '<w:r><w:t xml:space="preserve">${_x(value)}</w:t></w:r></w:p>';

  static String _x(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static const _contentTypes =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
      '</Types>';

  static const _rootRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
      '</Relationships>';

  static const _documentRels =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
      '</Relationships>';

  static const _styles =
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Garamond" w:hAnsi="Garamond"/><w:sz w:val="22"/></w:rPr></w:rPrDefault></w:docDefaults>'
      '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>'
      '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:color w:val="0000FF"/><w:sz w:val="26"/></w:rPr></w:style>'
      '</w:styles>';
}
