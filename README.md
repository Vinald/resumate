# Resumate

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
| **Signature** | Pick one signature image; it's decoded and re-encoded to a real PNG on pick (so a HEIC/WebP asset from the gallery can't silently break exports later), appears above your name on letter PDFs, and ships alongside `.tex` exports as `signature.png`. |
| **PDF combiner** | Merge several PDFs (reorderable) into one, natively. |
| **Settings** | Default contact, accent colour, body font (EB Garamond / Helvetica / Times), page margin, line spacing. |
| **Local-only** | Every document is a JSON file in the app documents directory. No account, no network. |

---

## Getting started

New to the app itself (not the codebase)? See [`TUTORIAL.md`](TUTORIAL.md) for a
first-run walkthrough.

Requires the Flutter SDK (channel `stable`, version `3.38.5` — see CI).

```sh
flutter pub get
flutter run           # device or emulator
flutter run -d chrome # quick desktop preview (no persistence, no native PDF preview)
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

Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` for modern
phones. The release build strips unused `com.tom_roush.pdfbox` / JPEG-2000
classes via `android/app/proguard-rules.pro`.

**Release signing:** if `android/key.properties` doesn't exist, the release
build falls back to the debug key (fine for sideloading, not for a store
listing). To sign with a real upload key:

```sh
keytool -genkeypair -v -keystore android/app/upload-keystore.jks \
  -alias upload -keyalg RSA -keysize 2048 -validity 10957
cat > android/key.properties <<EOF
storePassword=<the password you just set>
keyPassword=<same password — PKCS12 keystores don't support a separate one>
keyAlias=upload
storeFile=upload-keystore.jks
EOF
```

Both `android/key.properties` and `android/app/*.jks` are gitignored — never
commit them. Back the keystore and its password up somewhere durable (a
password manager, not just this machine): losing it means you can never
publish an update to an existing Play Store listing under the same app.

**If a JDK error persists after `export JAVA_HOME=...`:** Flutter's own
`flutter config --jdk-dir` setting (stored outside the repo, in Flutter's tool
state) takes priority over the `JAVA_HOME` environment variable and can be
stuck pointing at an uninstalled JDK — the error message looks identical to
the "`JAVA_HOME` not set" case either way. Fix it directly:
`flutter config --jdk-dir=/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home`.
If a build was killed (e.g. `kill -9`, an interrupted `flutter run`) rather
than exited cleanly, a Gradle daemon or Kotlin compile daemon can also be left
running in the background pinned to the old JDK, causing the same symptom (or
a `VerifyError` from mixed Kotlin-runtime classpaths) even after the config is
fixed — check `ps aux | grep -E "GradleDaemon|KotlinCompileDaemon"` and kill
any stale ones.

### Building an iOS app

```sh
cd ios && pod install && cd ..
flutter build ios --release            # for the App Store, needs a signing team in Xcode
flutter build ios --release --no-codesign  # unsigned .app, for sideloading/dev only
```

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
    settings_store.dart        ChangeNotifier over AppSettings; debounces the disk write
    seed_data.dart             the placeholder CV / letters

  render/                native PDF
    pdf_theme.dart             loads bundled TTFs once, builds pw.ThemeData from settings
    pdf_components.dart        shared widgets (section header, tick bullet, icon+text, link)
    template_registry.dart     id -> template lookup (the extension point)
    resume_template.dart / letter_template.dart   abstract interfaces
    classic_blue_template.dart / classic_letter_template.dart   the defaults
    document_pdf.dart          buildDocumentPdf(doc, settings, {pageFormat}) -> Uint8List

  latex/                 .tex generation
    latex_engine.dart          latexEscape() + token substitution into the templates
    tokens.dart                <<TOKEN>> catalogue shown in the LaTeX editor

  export/
    export_service.dart        writeToFile() + share() for every format
    filename.dart               safe, collision-free export base filenames
    docx_export.dart           WordprocessingML zip via `archive`
    tex_export.dart            thin wrapper over LatexEngine
    text_export.dart           plain text + Markdown

  pdf_tools/
    pdf_combiner_service.dart   wraps the `pdf_combiner` plugin

  ui/
    home/            document list (Resumes / Letters tabs), create / rename / duplicate / delete
    resume_editor/   the resume form (contact_section.dart is shared with the letter editor & settings)
    letter_editor/   the letter form
    latex_editor/    read-mostly .tex view (edits are a scratch buffer — not saved back; the
                     screen says so)
    preview/         PdfPreview of the live document, page-format selector wired through to it
    export/          the "Export as" bottom sheet
    pdf_combiner/    add / reorder / merge PDFs
    settings/        default contact + style + signature
    widgets/         EditorField, StringListEditor, EntryControls, SectionCard, SignaturePicker

assets/
  templates/         resume_classic.tex, cover_letter.tex, application_letter.tex  (<<TOKENS>>)
  fonts/             EB Garamond (body, instanced from the variable font) + Font Awesome 6
```

### Layers at a glance

```
UI (provider + ChangeNotifier)
      │  reads/writes
      ▼
Stores  ── DocumentStore, SettingsStore  (in-memory + notify)
      │  delegates persistence
      ▼
Repositories ── DocumentRepository, SettingsRepository  (JSON files)
      │
      ▼
Models ── ContactInfo, ResumeData, LetterData, GeneratedDocument, AppSettings

Output modules (pure functions over Model + AppSettings):
  render/   → PDF bytes
  latex/    → .tex string
  export/   → PDF / DOCX / txt / md / tex to a file, then the share sheet
  pdf_tools/→ merge N PDFs
```

Nothing in the output modules touches the stores or the repositories. They take
a `GeneratedDocument` and an `AppSettings` and return bytes or a string. The
only I/O they do is `rootBundle` reads of the bundled `.tex` templates and
TTFs, and reading the signature image file by path.

**Data flow.** Editors work on a `.copy()` of the document, mutate it locally,
and write back through `DocumentStore.save` (autosave on back-navigation, plus
an explicit Save FAB). `DocumentStore` / `SettingsStore` are `ChangeNotifier`s
provided at the root via `provider`. Rendering (`render/`, `latex/`, `export/`)
is pure: `(GeneratedDocument, AppSettings) -> bytes/string`, no I/O beyond
reading the bundled templates and the signature file.

### Models (`lib/models/`)

Plain mutable classes. Every one has:

- a positional/named constructor with defaults (so a "blank" instance is valid),
- `toJson()` / `fromJson()` — `fromJson` is defensive: every field has a
  fallback, unknown enum values fall back to the first case, missing lists
  become empty lists,
- `copy()` / `copyWith()` — deep copies for the "edit a copy, commit on save"
  pattern.

`GeneratedDocument` holds metadata plus **exactly one** of `resume` / `letter`
(nullable, chosen by `type`). `toJson` only serialises the non-null one.

`LetterData` owns the `{{placeholder}}` mechanism:

- `placeholderNames` — scans `companyName`, `companyAddress`, `salutation`,
  `recipientDept` and every body paragraph for `{{token}}` and returns the
  distinct names. The letter editor renders one field per name.
- `resolve(text)` — substitutes from the `placeholders` map; an unset/empty
  value renders as `[name]` so nothing silently disappears.

`AppSettings.accentColor` is a single ARGB int. `accentRgb` splits it into
`"R, G, B"` for the `<<ACCENT_RGB>>` LaTeX token.

### Persistence (`lib/data/`)

`DocumentRepository` — one `<uuid>.json` per document under a `documents/`
subdirectory of the app documents directory (`path_provider`). `loadAll` skips
files that fail to parse rather than failing the whole load. A `baseDir` can be
injected for tests.

`SettingsRepository` — a single `settings.json`. Missing or corrupt file →
`AppSettings()` defaults.

`DocumentStore` (`ChangeNotifier`):

- `load()` — if the repo is empty, writes `SeedData.initialDocuments()`, then
  loads all. **If any storage call throws** (e.g. web, where `path_provider`
  has no backing dir) it logs and runs from an in-memory copy of the seed data
  — the app still works, it just doesn't persist.
- `save` / `delete` / `create` / `duplicate` — mutate the in-memory list, call
  the repo (swallowing storage errors), `notifyListeners`, keep the list
  sorted by `updatedAt` desc.

`SettingsStore` is the same shape over a single `AppSettings`, except `update`
notifies listeners synchronously but debounces the actual `settings.json`
write by ~400ms, so dragging a slider doesn't fire one file write per frame.

Both stores are created in `main.dart` and their `load()` is started but
**not awaited** — the UI shows a spinner while `loading` is true.

### Rendering (`lib/render/`)

`PdfTheme.create(settings)` loads the four EB Garamond faces (or Helvetica /
Times) and the two Font Awesome TTFs **once** (static cache) and builds a
`pw.ThemeData`. It also carries the accent `PdfColor`, the margin in points and
the line spacing.

`ClassicBlueTemplate` / `ClassicLetterTemplate` build a `pw.MultiPage` (default
A4, but the page format is a parameter — `PreviewScreen` threads the format the
user picks in its toolbar straight through). Section visibility is data-driven:
an empty list means no heading. `PdfComponents` holds the shared bits — the
centred uppercase accent heading + rule, the `✓` bullet (Font Awesome check
glyph in the accent colour), the icon+text pairs on the contact line, and
`UrlLink` wrappers. The letter template guards its `pw.MemoryImage` signature
render in a try/catch, so a corrupt signature file degrades to "no image"
instead of failing the whole PDF.

`buildDocumentPdf(doc, settings, {pageFormat})` picks the template from
`TemplateRegistry.resume(doc.templateId)` for resumes, and always
`classic_letter` for letters, reading the signature bytes from disk first if a
path is set and the file exists.

### LaTeX (`lib/latex/`)

`latexEscape(input)` maps the ten LaTeX-special characters rune-by-rune in a
single pass (so the `{}` introduced by escaping `\` are not re-escaped).

`LatexEngine.render(doc, settings)`:

1. loads the right template from `assets/templates/` (injectable loader for
   tests),
2. builds a `Map<String,String>` of `TOKEN → value`, running free text through
   `latexEscape` and generating the repeated blocks (`_experienceItems`,
   `_skillItems`, `_educationItems`, `_projectItems`, `_references`),
3. `template.replaceAll('<<$key>>', value)` for each entry.

Letter bodies are `resolve()`d (placeholders) **before** escaping. `<<DATE>>`
falls back to `\today` when blank; `<<SIGNATURE_IMAGE>>` emits an
`\includegraphics` line only when a signature path is set.

`PORTFOLIO_URL` / `GITHUB_URL` / `LINKEDIN_URL` go into `\href{...}` through
`texUrl()`, not `latexEscape()` — LaTeX-escaping a URL (backslash commands
like `\%`) would break it as a URL. `texUrl()` instead percent-encodes just
the two characters that break a raw `\href` URL argument (`#`, TeX's
macro-parameter character, and an unescaped `%`, a comment character),
leaving an already-valid `%XX` escape untouched.

### Export (`lib/export/`)

`ExportService.writeToFile(doc, settings, format)` builds a safe, collision-free
base filename via `filename.dart` (the title slugified, with a short suffix of
the document's own id — closes both the "all-punctuation title slugifies to
nothing" and "two differently-punctuated titles collide" cases), writes to a
temp file, and dispatches on `ExportFormat`. `share()` additionally attaches
`signature.png` next to a letter `.tex` so it drops straight into Overleaf.

`DocxExport` builds the five-part OOXML zip by hand
(`[Content_Types].xml`, `_rels/.rels`, `word/_rels/document.xml.rels`,
`word/styles.xml`, `word/document.xml`) with `archive`. Layout is intentionally
plain — headings, bold runs, literal `✓` bullets — so it opens clean and stays
editable in Word. XML text is escaped via `_x()`.

`TextExport` produces plain text (UPPERCASE headings) or Markdown (`#`
headings), sharing the section walk.

### UI (`lib/ui/`)

`provider` supplies `DocumentStore` and `SettingsStore` from the root.

`HomeScreen` — `DefaultTabController` (Resumes / Letters), a FAB that opens a
type picker then the matching editor, per-row popup menu (rename / duplicate /
delete with confirm).

`ResumeEditorScreen` / `LetterEditorScreen` — `StatefulWidget`s holding a
`.copy()` of the payload and a `_dirty` flag. `PopScope` autosaves on back.
Every `onChanged` runs through `_edit(() {...})` which mutates the copy and
`setState`s. List sections use a private `_EntryFrame` with move-up/down/delete.

`contact_section.dart` is shared by both editors and the settings screen.

`LatexEditorScreen` — generates the `.tex` into a `TextEditingController` on
open. Copy / Share use the (possibly edited) buffer; there's no save-back, and
the screen shows a dismissible banner saying so.

`SettingsScreen` — writes through `SettingsStore.update` on every change; the
store itself debounces the actual disk write (see Persistence above).

`PdfCombinerScreen` — `ReorderableListView` of picked PDFs, `_combine()` calls
`PdfCombinerService.merge`, shows a `PdfPreview` of the result and a share
action.

### Testing seams

- `DocumentRepository(baseDir:)` / `SettingsRepository(baseDir:)` — temp dir.
- `LatexEngine(loadAsset:)` — load templates from disk instead of `rootBundle`.
- Output modules are pure, so most tests are `SeedData → module → assert on the
  string/bytes`.

### Adding a template

1. Implement `ResumeTemplate` / `LetterTemplate` in `lib/render/`.
2. Register it in `TemplateRegistry` (`resumeTemplates` / `letterTemplates`).
3. `GeneratedDocument.templateId` selects it per document (defaults to
   `classic_blue`). There is currently no UI to switch templates.

---

## Dependency notes

- `pdf`, `printing` and `archive` are pinned below their latest majors because
  those majors require Dart SDK `>=3.12.0`, and this project targets
  `sdk: ^3.10.4` (`pubspec.yaml`). Bumping the SDK constraint (and the Flutter
  version CI pins) is a deliberate, separately-tested change, not a drive-by
  dependency bump.
- **Web PDF preview** uses `printing`'s pdf.js integration; `web/index.html`
  pins the pdf.js version so the API and worker match. The in-app preview is
  really meant for Android / iOS (native renderer).
- **Fonts** are declared under `fonts:` in `pubspec.yaml` and loaded via
  `rootBundle` in `render/pdf_theme.dart`.
- **App icon / splash screen** are generated from `assets/icon/` (a blue
  `#0000FF` "R" monogram in EB Garamond Bold, matching the in-app look) via
  the `flutter_launcher_icons` / `flutter_native_splash` dev tools, configured
  in `pubspec.yaml`. To regenerate after changing the source images:
  `dart run flutter_launcher_icons && dart run flutter_native_splash:create`.

---

## Testing

```sh
flutter analyze
flutter test
```

53 tests cover: model JSON round-trips, `DocumentRepository` CRUD + sort,
seed-data shape, the LaTeX token engine + escaping (including `texUrl`'s
percent-encoding of `#`/`%` in contact URLs), DOCX zip structure +
placeholder resolution + XML escaping, plain-text / Markdown output, raw PDF
rendering (resume + letter), the reorderable list editor, the first-launch
tutorial prompt, signature image re-encoding, the resume editor's dirty-state
flow, and a widget-test smoke pass over every remaining screen: `Settings`,
`Preview`, `LatexEditor` (load/banner/tokens/copy), `PdfCombiner`,
`ExportSheet`, and `contact_section.dart`.

CI (`.github/workflows/ci.yml`) runs `flutter pub get` / `analyze` / `test` /
a debug APK build on every push to `main` and every PR.

Two non-obvious gotchas beyond the two already documented at the top of
`test/home_screen_tutorial_test.dart`, hit while adding the screen tests
above:

- `rootBundle.loadString` (asset loading, e.g. `LatexEngine`'s templates)
  resolves fine within a *single* `testWidgets`, but a **second**,
  independent `testWidgets` in the same file/isolate that loads the same
  asset again can hang forever instead of returning the cached result — see
  the comment at the top of `test/latex_editor_screen_test.dart`. Fixed by
  covering everything that needs the loaded screen in one combined test
  rather than one `testWidgets` per scenario.
- A screen taller than the default 800×600 test surface (`SettingsScreen`)
  needs either scrolling or a resized `tester.view.physicalSize` before its
  lower widgets are hit-testable — see `test/settings_screen_test.dart`.
  Plain `scrollUntilVisible()` can also pick the wrong `Scrollable` when the
  page has `TextFormField`s (each has its own internal horizontal one).

---

## Known limitations

- LaTeX editor edits are a scratch buffer and are not saved back to the
  document (the screen says so).
- A brand-new resume starts pre-filled with the whole seed CV instead of
  blank — a deliberate-but-debatable default in `DocumentStore.create`.
- `pdf` / `printing` / `archive` are held below their latest majors pending a
  Dart SDK bump (see Dependency notes).
- No `==`/`hashCode` on the data models.

## Contributing

```sh
flutter pub get
flutter run           # device or emulator
flutter run -d chrome # quick desktop preview (no persistence, no native PDF preview)
```

Flutter `stable` `3.38.5` (matches CI). Android release builds need JDK 21
(see above).

**Before you push:**

```sh
flutter analyze   # must be clean
flutter test      # must be green
```

CI runs exactly these (plus a debug APK build) on every PR.

**Conventions:**

- **Commits:** one-line imperative subject ("Add signature image to letter
  PDF"). No trailers.
- **Branches:** `fix/…`, `chore/…`, `docs/…`, `feat/…`. One logical change per
  branch / PR.
- **Dart style:** the repo default (`flutter_lints`). Keep trailing commas so
  the formatter lays widgets out vertically. Run `dart format .` if in doubt.
- Models stay plain: constructor with defaults, `toJson` / `fromJson`
  (defensive), `copy` / `copyWith`. If you add a field, update all four plus
  any affected test in `test/models_serialization_test.dart`.
- Output modules (`render/`, `latex/`, `export/`) must stay pure — take
  `GeneratedDocument` + `AppSettings`, return bytes / string, no store access.
- Add a test with any behaviour change. Repositories and the LaTeX engine have
  injection seams (`baseDir:`, `loadAsset:`) — see Testing seams above.

**Common tasks:**

| Task | Start here |
| --- | --- |
| New export format | `export/export_service.dart` (`ExportFormat` enum + `switch`) |
| New PDF template | implement `render/*_template.dart`, register in `template_registry.dart` |
| New LaTeX token | `latex/latex_engine.dart` (the token map) + `latex/tokens.dart` (the doc) + the `.tex` files in `assets/templates/` |
| New resume/letter field | `models/` → the editor screen → the four renderers (`classic_blue_template`, `classic_letter_template`, `latex_engine`, `docx_export`, `text_export`) |
| Change the sample CV | `lib/data/seed_data.dart` (keep it generic placeholder content) |

## License

MIT — see [`LICENSE`](LICENSE).

## Support

Questions, bugs, or feature requests: open an issue on this repo, or reach the
maintainer directly at **okiror1vinald@gmail.com**.
