import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/resume.dart';
import 'pdf_theme.dart';

/// A resume renderer. Implementations turn [ResumeData] into a [pw.Document].
abstract class ResumeTemplate {
  String get id;
  String get name;

  pw.Document build(
    ResumeData data,
    PdfTheme theme, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  });
}
