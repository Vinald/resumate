import '../models/document.dart';

/// Turns a document's title into a filesystem-safe base name (no extension),
/// guaranteed non-empty and unique per document.
///
/// The plain slugify-the-title approach used to collide two ways: an
/// all-non-ASCII title (or one that's pure punctuation) slugifies to an empty
/// string, and two differently-punctuated titles — "Resume (Draft)" and
/// "Resume [Draft]" — both slugify to the same "Resume_Draft_". Appending a
/// short slice of the document's own id closes both gaps.
String safeExportFilename(GeneratedDocument doc) {
  final slug = doc.title
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final base = slug.isEmpty ? 'document' : slug;
  final suffix = doc.id.length >= 6 ? doc.id.substring(0, 6) : doc.id;
  return '${base}_$suffix';
}
