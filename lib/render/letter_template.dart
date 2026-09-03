import 'package:pdf/widgets.dart' as pw;

import '../models/letter.dart';
import 'pdf_theme.dart';

/// A letter renderer. [signature] is optional PNG/JPG bytes.
abstract class LetterTemplate {
  String get id;
  String get name;

  pw.Document build(LetterData data, PdfTheme theme, {List<int>? signature});
}
