# Code Review — Resume Generator

Deep review of the Flutter app on `main` as of commit `f08bb67`.
Scope: `lib/`, `test/`, `assets/templates/`, platform config (`android/`, `ios/`,
`web/`), build/CI wiring. Third-party `ios/Pods/` is out of scope.

Overall the codebase is small, cleanly layered (models → repositories → stores →
UI, with `render/`, `export/`, `latex/` as pure output modules) and well tested at
the unit level. `flutter analyze` is clean and `flutter test` (24 tests) passes.
The issues below are mostly edge cases, platform-config gaps and UX rough edges
rather than structural problems.

Severity key: **High** = crash or data loss for a normal user · **Medium** =
broken output or bad UX in a common path · **Low** = minor / cosmetic / hardening
· **Info** = observation, no action required.

---

## High

### H1 · iOS: signature picker crashes — missing `NSPhotoLibraryUsageDescription`

`ios/Runner/Info.plist` has no photo-library usage string. `SignaturePicker`
(`lib/ui/widgets/signature_picker.dart:19`) calls
`ImagePicker().pickImage(source: ImageSource.gallery)`. On iOS, opening the photo
library without `NSPhotoLibraryUsageDescription` in `Info.plist` is an immediate
hard crash (`SIGABRT`), not a permission denial. Any user who taps **Add
signature** on iOS loses the app.

**Fix:** add to `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Select a signature image to place on your letters.</string>
```

(`image_picker` also reads `NSCameraUsageDescription` / `NSMicrophoneUsageDescription`
only if the camera source is used — it is not here, so those are optional but
cheap to add for future-proofing.)

Addressed in PR *fix/safe-bugs*.

---

## Medium

### M1 · Editor text fields show stale text after reordering an entry

Affects every list section in the resume editor (Employment, Technical Skills,
Education, Projects, References) and the paragraph/bullet lists.

`EditorField` (`lib/ui/widgets/editor_widgets.dart:46`) is a `StatelessWidget`
wrapping `TextFormField(initialValue: value)` **with no `Key`**. `initialValue`
seeds the field's internal `TextEditingController` **once**; later rebuilds with a
different `value` are ignored. `_EntryFrame`
(`lib/ui/resume_editor/resume_editor_screen.dart:471`) also has no key, so when
`_reorder` swaps two entries in the backing list, Flutter reuses the existing
`FormFieldState`s **by position** and the fields keep displaying the previous
entry's text. The underlying model is reordered correctly, so an export or a
screen reopen shows the right data — but the editor is visibly wrong until then,
which invites the user to "fix" it and actually corrupt the data.

`StringListEditor` (`editor_widgets.dart:113`) keys its fields
`ValueKey('$label-$i-${values.length}')`. Because the key is index-based and the
length is unchanged by a reorder, the same stale-text problem applies to bullet
and paragraph reordering. (Deletion happens to work there only because the length
change rotates every key.)

**Fix:** key the moving subtree by the *identity* of its model object
(`ObjectKey(entry)`) for the `_EntryFrame` sections, and give `StringListEditor`
real per-row `TextEditingController`s that are reordered/inserted/removed in
lock-step with the list. Addressed in PR *fix/safe-bugs*.

### M2 · `.tex` export produces invalid LaTeX for contact fields with special characters

`lib/latex/latex_engine.dart` escapes most free text through `latexEscape`, but
**not** the URL/email tokens:

- `EMAIL` (`:64`) is inserted raw both into `\href{mailto:...}` *and* as the
  visible link text `{<<EMAIL>>}`. An address such as `jane_doe@example.com`
  emits a bare `_` in text mode → `Missing $ inserted` compile error.
- `PORTFOLIO_URL`, `GITHUB_URL`, `LINKEDIN_URL` (`:53–56`, `:82–86`) go straight
  into `\href{...}`. `#` and `%` in a URL break the argument; `~` and `&` are
  risky.

`GITHUB_LABEL` / `LINKEDIN_LABEL` *are* escaped, so only the URLs and the email
display text are exposed.

**Fix (template-only, no engine change needed):** wrap the visible email in
`\nolinkurl{}` (hyperref, handles `_ % # ~`): `\href{mailto:<<EMAIL>>}{\nolinkurl{<<EMAIL>>}}`.
For the `\href` targets, `\detokenize`/`\nolinkurl` or documenting the limitation
is acceptable since query-string URLs are rare in a CV. The email fix is applied
in PR *fix/safe-bugs*.

### M3 · Signature image is trusted to be a decodable PNG/JPEG

`SignaturePicker._pick` (`:23`) copies whatever the gallery returns to
`signature.png` verbatim — no re-encode, no MIME check. `image_picker` returns the
asset in its original container, so an iOS HEIC, a WebP or a GIF is now a file
named `.png` whose bytes are not PNG.

- PDF: `classic_letter_template.dart:104` feeds those bytes to
  `pw.MemoryImage`, which throws while building the document → letter preview and
  every letter export (PDF *and* the other formats route through the same
  `buildDocumentPdf` for preview) fail with an opaque error.
- `.tex`: the non-PNG file is shipped next to the source as `signature.png`;
  Overleaf then fails to include it.

**Fix:** decode + re-encode to PNG on pick (e.g. via `image` package or
`instantiateImageCodec`), reject/notify on failure, and guard `pw.MemoryImage`
with a try/catch so one bad image can't brick letter rendering. Documented;
not included in the *safe-bugs* PR because it needs a new dependency decision.

---

## Low

### L1 · Settings are written to disk on every keystroke and every slider frame

`SettingsScreen` calls `store.update(...)` from every `onChanged`
(`lib/ui/settings/settings_screen.dart` — default-contact fields, both sliders,
font dropdown, colour). `SettingsStore.update` (`settings_store.dart:27`)
`await`s `_repo.save`, a full `writeAsString` of `settings.json`, each time.
Dragging a slider issues dozens of overlapping writes per second. Not corrupting
(last write wins) but wasteful and a battery/flash concern.

**Fix:** debounce the persist (e.g. 300–500 ms trailing) or persist on
field-commit / screen-pop. Keep the in-memory update synchronous so the UI stays
live.

### L2 · "New resume" is pre-populated with the entire seed CV

`DocumentStore.create` (`data/document_store.dart:90`):

```dart
resume: type == DocumentType.resume ? SeedData.resume() : null,
```

A brand-new resume opens containing every seed job, skill and project, which the
user must delete. New *letters* correctly start near-empty. An `emptyResume()`
helper already exists in the same file (`:120`) but is only used by callers/tests.

**Fix:** use `emptyResume()` (contact only) for `create`, or add a
`ResumeData.blank()` with one empty entry per section. Left as a product call.

### L3 · `TextEditingController` leak in the rename dialog

`_promptText` (`ui/home/home_screen.dart:202`) news a `TextEditingController` and
never disposes it. Minor, but it's one per rename for the process lifetime.
Use a small `StatefulWidget` or dispose in a `.whenComplete`.

### L4 · PDF preview ignores the page-format selector

`PreviewScreen` (`ui/preview/preview_screen.dart`) passes
`build: (_) => buildDocumentPdf(doc, settings)` — the `PdfPageFormat` argument
from the preview toolbar is discarded, and the template hardcodes
`PdfPageFormat.a4`. Switching to Letter in the toolbar does nothing. Either
remove the control (`PdfPreview(..., canChangePageFormat: false)`) or thread the
format through the template.

### L5 · LaTeX editor edits are a scratch buffer with no save and no warning

`LatexEditorScreen` regenerates the source from document data on open and lets
the user edit it, but there is no "save" — **Copy** and **Share .tex** use the
edited text, everything else re-renders from the model, and navigating back
silently discards the edits. This is a defensible design (the model is the source
of truth) but nothing tells the user. Add a one-line banner ("Edits here are not
saved — use Copy or Share") or a discard confirmation.

### L6 · Empty "References" section renders inconsistently across formats

`ClassicBlueTemplate._references` (`render/classic_blue_template.dart:217`) hides
the section entirely when there are no references and the on-request note is
blank. The `.tex` templates hard-code the `References` heading + rule, and
`latex_engine._references` / `DocxExport` / `TextExport` always emit *something*.
Same document, four outputs, different structure. Pick one rule (probably "hide
when empty") and apply it everywhere.

### L7 · Export temp filenames can collide or degenerate

`ExportService.writeToFile` (`export/export_service.dart:34`):
`doc.title.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')`. A title that is all
non-ASCII (e.g. non-Latin script) collapses to `_` or `""` → `_.pdf` / `.pdf`;
two documents titled "CV (2024)" and "CV 2024" both become `CV_2024.<ext>` and
overwrite each other in the temp dir before sharing. Append the document id or a
timestamp, and fall back to `"document"` when the slug is empty.

### L8 · Android app label is the raw package name

`android/app/src/main/AndroidManifest.xml`: `android:label="resume_generator"`.
iOS shows "Resume Generator" (`CFBundleDisplayName`); Android shows
`resume_generator` under the launcher icon. Set `android:label="Resume Generator"`.
Applied in PR *fix/safe-bugs*.

### L9 · `web/` still carries Flutter-template metadata

`web/index.html`: `<meta name="description" content="A new Flutter project.">`
and `apple-mobile-web-app-title` / `manifest.json` `name` use `resume_generator`.
Cosmetic, but it's what a browser tab / PWA install surfaces.

### L10 · No `FlutterError` / zone error handling, fire-and-forget bootstrap

`main.dart` starts `DocumentStore(..)..load()` and `SettingsStore(..)..load()`
without awaiting and without a `runZonedGuarded` / `FlutterError.onError` hook.
The stores each catch their own load failures and fall back, so this is not
urgent, but there's no crash telemetry seam and an exception thrown between
`ensureInitialized()` and `runApp()` would be invisible.

### L11 · `DocumentRepository` scans the directory twice on startup and uses sync I/O

`DocumentStore.load` calls `_repo.isEmpty()` then `_repo.loadAll()`; both run
`dir.listSync()` (`data/document_repository.dart:33`, `:67`). Fine at 3 files,
O(2n) stat calls as the library grows, and `listSync` blocks the isolate. Use one
async `dir.list()` pass and derive "empty" from the result.

### L12 · `pdf_combiner_screen` re-reads the merged file on every rebuild

`_readBytes(_resultPath!)` is the `PdfPreview.build` callback
(`ui/pdf_combiner/pdf_combiner_screen.dart:117`), so any `setState` (e.g. adding
another file) re-reads the whole combined PDF from disk. Cache the bytes when the
merge completes.

---

## Info / observations

- **I1 — No widget or integration tests.** The 24 unit tests cover models,
  repositories, seed data, the LaTeX engine, DOCX/text output and raw PDF
  rendering well. Editors, navigation, the export sheet, the PDF combiner and the
  signature flow have no coverage — and M1 is exactly the kind of bug a widget
  test would have caught.
- **I2 — Model equality.** No `==` / `hashCode` on `ContactInfo`, `ResumeData`,
  `LetterData`, entries. Editors call `.copy()` on the whole document on every
  keystroke (`resume_editor_screen.dart:35`). Harmless at CV scale; worth a note.
- **I3 — Release APK is debug-signed.** Already flagged with a `TODO` in
  `android/app/build.gradle.kts` and in the README. Fine for sideloading, blocks
  Play Store.
- **I4 — `analysis_options.yaml` is the stock template.** Consider adding
  `flutter_lints` extras you care about (`require_trailing_commas`,
  `unawaited_futures`, `use_build_context_synchronously` is already on via the
  Flutter set).
- **I5 — `assets/fonts/` is declared only under `fonts:` in `pubspec.yaml`, not
  `assets:`.** It works (font assets are bundled and `rootBundle.load`-able, and
  `pdf_render_test` proves it), but adding `- assets/fonts/` under `assets:` makes
  the intent explicit and is what the `pdf` package docs recommend.
- **I6 — `.tex` templates load `fontawesome5`** while the app comment
  (`render/pdf_theme.dart`) and README say "Font Awesome 6". The glyph commands
  used (`\faGithub`, `\faLinkedin`, …) exist in both; just a doc mismatch.
- **I7 — `settings_screen.dart` has a misplaced `// ignore: use_build_context_synchronously`.**
  The `update(...)` call after the colour dialog uses a `store` reference
  captured at build time, not `context`, so nothing is actually being ignored.
- **I8 — `com.vinald.*` application id / bundle id.** A developer namespace
  rather than personal data; left as-is. Renaming touches the Kotlin package
  directory and the Xcode project and is easy to get wrong — do it deliberately
  if the repo is going public under a different owner.
- **I9 — `devtools_options.yaml`** is untracked and should be git-ignored
  (handled in PR *docs/project-documentation*).

---

## Suggested fix batches

| PR | Contents |
| --- | --- |
| `fix/safe-bugs` | H1, M1, M2 (email), L8 |
| follow-up (needs a call) | M3, L1, L2, L4, L5, L6, L7 |
| hardening | L3, L10, L11, L12, I1, I5 |
