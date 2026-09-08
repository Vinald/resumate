# Resume Generator

A Flutter app (Android + iOS, with web builds for quick previews) for building
**resumes**, **cover letters** and **application letters** on your phone and
exporting them to PDF, Word, plain text, Markdown or LaTeX.

It replaces an Overleaf workflow: the same blue-heading, `✓`-bullet look is
reproduced natively so you can edit content in structured forms and get a
finished document without touching LaTeX — but the real `.tex` source is still
one tap away when you want pixel-exact Overleaf output.

The app ships with a generic placeholder CV ("Alex Doe" at fictional companies).
Edit it in place, or replace `lib/data/seed_data.dart`, to make it yours.

---

## Features

| | |
| --- | --- |
| **Structured editing** | Contact, summary, experience, skills, education, projects, references — each a form with add / reorder / delete. Letters have recipient, body paragraphs, sign-off and `{{placeholder}}` fields. |
| **Native PDF** | Rendered with the `pdf` package to match the LaTeX template (blue `#0000FF` headings, accent rules, `✓` bullets, EB Garamond body, Font Awesome contact icons). |
| **Exports** | PDF · DOCX (hand-built WordprocessingML) · plain text · Markdown · LaTeX `.tex` (fills the real templates in `assets/templates/`). |
| **LaTeX source view** | See and copy/share the generated `.tex`, with a token reference panel. |
| **Signature** | Pick one signature image; it appears above your name on letter PDFs and is shipped alongside `.tex` exports as `signature.png`. |
| **PDF combiner** | Merge several PDFs (reorderable) into one, natively. |
| **Settings** | Default contact, accent colour, body font (EB Garamond / Helvetica / Times), page margin, line spacing. |
| **Local-only** | Every document is a JSON file in the app documents directory. No account, no network. |

---

## Getting started

Requires the Flutter SDK (channel `stable`, version `3.38.5` — see CI).

```sh
flutter pub get
flutter run
```

First-time toolchain setup:

- **Android:** `flutter doctor --android-licenses` and accept.
- **iOS:** `brew install cocoapods` (or `sudo gem install cocoapods`), then
  `cd ios && pod install`. `Podfile.lock` is committed; the deployment target is
  pinned to iOS 13.0.
- **Web** (desktop previews only): `flutter run -d chrome`.

### Building a release APK

Gradle needs **JDK 21** — JDK 25/26 on `PATH` will fail the build:

```sh
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (~32 MB) for
modern phones. It is **signed with the debug key** — fine for sideloading,
replace with a real signing config before publishing (`android/app/build.gradle.kts`).
The release build strips unused `com.tom_roush.pdfbox` / JPEG-2000 classes via
`android/app/proguard-rules.pro`.

---

## Architecture

```
lib/
  main.dart              bootstrap: build the stores, kick off load(), runApp
  app.dart               MaterialApp + theme (Material 3, blue seed)

  models/                plain data classes with toJson / fromJson / copy
    contact_info.dart      name, title, phone, email, portfolio, GitHub, LinkedIn
    resume.dart            ResumeData + Experience / Skill / Education / Project / Reference
    letter.dart            LetterData (+ {{placeholder}} resolution), LetterKind
    document.dart          GeneratedDocument (metadata + one of resume/letter), DocumentType
    app_settings.dart      AppSettings, BodyFont

  data/                  persistence
    document_repository.dart   one <id>.json per document under documents/
    settings_repository.dart   single settings.json
    document_store.dart        ChangeNotifier: in-memory list, seeds on first run,
                               falls back to in-memory seed data if storage fails
    settings_store.dart        ChangeNotifier over AppSettings
    seed_data.dart             the placeholder CV / letters

  render/                native PDF
    pdf_theme.dart             loads bundled TTFs once, builds pw.ThemeData from settings
    pdf_components.dart        shared widgets (section header, tick bullet, icon+text, link)
    template_registry.dart     id -> template lookup (the extension point)
    resume_template.dart / letter_template.dart   abstract interfaces
    classic_blue_template.dart / classic_letter_template.dart   the defaults
    document_pdf.dart          buildDocumentPdf(doc, settings) -> Uint8List

  latex/                 .tex generation
    latex_engine.dart          latexEscape() + token substitution into the templates
    tokens.dart                <<TOKEN>> catalogue shown in the LaTeX editor

  export/
    export_service.dart        writeToFile() + share() for every format
    docx_export.dart           WordprocessingML zip via `archive`
    tex_export.dart            thin wrapper over LatexEngine
    text_export.dart           plain text + Markdown

  pdf_tools/
    pdf_combiner_service.dart   wraps the `pdf_combiner` plugin

  ui/
    home/            document list (Resumes / Letters tabs), create / rename / duplicate / delete
    resume_editor/   the resume form (contact_section.dart is shared with the letter editor & settings)
    letter_editor/   the letter form
    latex_editor/    read-mostly .tex view (edits are a scratch buffer — not saved)
    preview/         PdfPreview of the live document
    export/          the "Export as" bottom sheet
    pdf_combiner/    add / reorder / merge PDFs
    settings/        default contact + style + signature
    widgets/         EditorField, StringListEditor, EntryControls, SectionCard, SignaturePicker

assets/
  templates/         resume_classic.tex, cover_letter.tex, application_letter.tex  (<<TOKENS>>)
  fonts/             EB Garamond (body, instanced from the variable font) + Font Awesome 6
```

**Data flow.** Editors work on a `.copy()` of the document, mutate it locally,
and write back through `DocumentStore.save` (autosave on back-navigation, plus an
explicit Save FAB). `DocumentStore` / `SettingsStore` are `ChangeNotifier`s
provided at the root via `provider`. Rendering (`render/`, `latex/`, `export/`)
is pure: `(GeneratedDocument, AppSettings) -> bytes/string`, no I/O beyond
reading the bundled templates and the signature file.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for a deeper walkthrough and
[`REVIEW.md`](REVIEW.md) for a catalogue of known bugs and rough edges.

### Adding a template

1. Implement `ResumeTemplate` / `LetterTemplate` in `lib/render/`.
2. Register it in `TemplateRegistry` (`resumeTemplates` / `letterTemplates`).
3. `GeneratedDocument.templateId` selects it per document (defaults to
   `classic_blue`). There is currently no UI to switch templates.

---

## Dependency notes

- **`dependency_overrides: file_magic_number: 1.2.0`** is required — `pdf_combiner`
  3.4.0 imports a file that `file_magic_number` 1.3.0 moved out of the package
  root. Pinned to the last version that still exposes it.
- **Web PDF preview** uses `printing`'s pdf.js integration; `web/index.html` pins
  the pdf.js version so the API and worker match. The in-app preview is really
  meant for Android / iOS (native renderer).
- **Fonts** are declared under `fonts:` in `pubspec.yaml` and loaded via
  `rootBundle` in `render/pdf_theme.dart`.

---

## Testing

```sh
flutter analyze
flutter test
```

24 unit tests cover: model JSON round-trips, `DocumentRepository` CRUD + sort,
seed-data shape, the LaTeX token engine + escaping, DOCX zip structure +
placeholder resolution + XML escaping, plain-text / Markdown output, and raw PDF
rendering (resume + letter).

There are **no widget or integration tests** yet — see `REVIEW.md` (I1).

CI (`.github/workflows/ci.yml`) runs `flutter pub get` / `analyze` / `test` on
every push to `main` and every PR.

---

## Known limitations

Short list — the full analysis is in [`REVIEW.md`](REVIEW.md).

- **iOS:** the signature picker needs `NSPhotoLibraryUsageDescription` in
  `Info.plist` (fix in flight).
- Reordering an entry in the resume editor can leave stale text in the form
  fields until the screen is reopened.
- `.tex` export doesn't escape URLs / email addresses, so LaTeX-special
  characters (`_`, `#`, `%`) in those fields break compilation.
- LaTeX editor edits are not persisted.
- Release APK is debug-signed.
