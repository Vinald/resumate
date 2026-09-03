import '../latex/latex_engine.dart';
import '../models/app_settings.dart';
import '../models/document.dart';

/// Fills the bundled `.tex` template for [doc] and returns the source.
Future<String> buildDocumentTex(
  GeneratedDocument doc,
  AppSettings settings,
) {
  return LatexEngine().render(doc, settings);
}
