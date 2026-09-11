# Code Review — Resumate

Living review document. First pass Sep 2026 against commit `f08bb67`
(then "Resume Generator"); this update is a full re-pass against `main` after
PRs #1–#8 (anonymized seed data, renamed to Resumate, visual theme pass,
in-app tutorial, the H1/M1/M2/L8 fixes below) — scope widened to include a
dependency/toolchain audit, a security pass, and a test-coverage gap analysis.
Scope: `lib/`, `test/`, `assets/templates/`, platform config (`android/`,
`ios/`, `web/`), build/CI wiring, `pubspec.yaml`. Third-party `ios/Pods/` is
out of scope.

`flutter analyze` is clean and `flutter test` (32 tests) passes, on this
machine and in CI.

Severity key: **High** = crash or data loss for a normal user · **Medium** =
broken output or bad UX in a common path · **Low** = minor / cosmetic /
hardening · **Info** = observation, no action required.

## Status of the original findings

| # | Finding | Status |
| --- | --- | --- |
| H1 | iOS signature picker crash (missing `NSPhotoLibraryUsageDescription`) | ✅ Fixed, PR #4 |
| M1 | Editor fields show stale text after reordering | ✅ Fixed, PR #4 |
| M2 | `.tex` export breaks on emails with `_` | ✅ Fixed (email case), PR #4 |
| M3 | Signature image not re-encoded / validated | 🔶 Still open |
| L1 | Settings written to disk on every keystroke | 🔶 Still open |
| L2 | "New resume" pre-filled with the whole seed CV | 🔶 Still open |
| L3 | Controller leak in rename dialog | 🔶 Still open |
| L4 | PDF preview page-format selector is a no-op | 🔶 Still open |
| L5 | LaTeX editor edits are an unsaved scratch buffer | 🔶 Still open |
| L6 | Empty References renders inconsistently across formats | 🔶 Still open |
| L7 | Export temp filenames can collide | 🔶 Still open |
| L8 | Android launcher label was the raw package name | ✅ Fixed, PR #4 (now "Resumate", PR #5) |
| L9 | Leftover Flutter-template web metadata | ✅ Fixed, PR #5 |
| L10–L12 | Zone error handling, double dir scan, combiner re-read | 🔶 Still open |
| I9 | `devtools_options.yaml` untracked/gitignored | ✅ Fixed this pass (see C4 below) — it had been re-added to git by an intervening commit despite the `.gitignore` entry |

The full text of each original finding is kept below unchanged, for context on
*why*; new material starts at **Fresh findings**.

---

## High

### H1 · iOS: signature picker crashes — missing `NSPhotoLibraryUsageDescription` — ✅ Fixed (PR #4)

`ios/Runner/Info.plist` has no photo-library usage string. `SignaturePicker`
(`lib/ui/widgets/signature_picker.dart:19`) calls
`ImagePicker().pickImage(source: ImageSource.gallery)`. On iOS, opening the photo
library without `NSPhotoLibraryUsageDescription` in `Info.plist` is an immediate
hard crash (`SIGABRT`), not a permission denial. Any user who taps **Add
signature** on iOS loses the app.

**Fix:** added `NSPhotoLibraryUsageDescription` to `Info.plist`.

---

## Medium

### M1 · Editor text fields show stale text after reordering an entry — ✅ Fixed (PR #4)

`EditorField` (`lib/ui/widgets/editor_widgets.dart`) was a `StatelessWidget`
wrapping `TextFormField(initialValue: value)` **with no `Key`**. `initialValue`
seeds the field's internal `TextEditingController` **once**; later rebuilds with a
different `value` were ignored, so reordering an entry left the editor showing
stale text until reopened (the underlying model was fine).

**Fix:** `_EntryFrame` now keyed by `ObjectKey(entry)`; `StringListEditor`
rewritten stateful with one `TextEditingController` per row, reordered in
lock-step with the list. Regression-covered by `test/string_list_editor_test.dart`.

### M2 · `.tex` export produces invalid LaTeX for contact fields with special characters — ✅ Fixed for the email case (PR #4)

`lib/latex/latex_engine.dart` escapes most free text through `latexEscape`, but
not the URL/email tokens — `EMAIL` was inserted raw both into `\href{mailto:...}`
*and* as the visible link text, so an address like `jane_doe@example.com` broke
`.tex` compilation with a bare `_` in text mode.

**Fix applied:** the three `.tex` templates now wrap the visible email in
`\nolinkurl{}` (`\href{mailto:<<EMAIL>>}{\nolinkurl{<<EMAIL>>}}`), which
hyperref reads verbatim.

**Still open, narrower:** `PORTFOLIO_URL`, `GITHUB_URL`, `LINKEDIN_URL` still go
straight into `\href{...}` unescaped — `#` and `%` in a URL would still break the
argument. Low priority (query-string URLs are rare in a CV's contact block) but
not actually fixed, just not the case that was addressed.

### M3 · Signature image is trusted to be a decodable PNG/JPEG — still open

`SignaturePicker._pick` copies whatever the gallery returns to `signature.png`
verbatim — no re-encode, no MIME check. `image_picker` returns the asset in its
original container, so an iOS HEIC, a WebP or a GIF is now a file named `.png`
whose bytes are not PNG.

- PDF: `classic_letter_template.dart` feeds those bytes to `pw.MemoryImage`,
  which throws while building the document → letter preview and every letter
  export fail with an opaque error.
- `.tex`: the non-PNG file is shipped next to the source as `signature.png`;
  Overleaf then fails to include it.

**Fix:** decode + re-encode to PNG on pick (e.g. via the `image` package,
already a transitive dependency via `image_picker`, or `instantiateImageCodec`),
reject/notify on failure, and guard `pw.MemoryImage` with a try/catch so one bad
image can't brick letter rendering. Not included in PR #4 because it needs an
explicit dependency decision (`image` is currently transitive-only).

---

## Low

*(unchanged from the original pass except L8/L9, marked above; kept for
context — see the status table for what's still open.)*

### L1 · Settings are written to disk on every keystroke and every slider frame

`SettingsScreen` calls `store.update(...)` from every `onChanged`. Dragging a
slider issues dozens of overlapping file writes per second. Not corrupting
(last write wins) but wasteful and a battery/flash concern. **Fix:** debounce
the persist (300–500 ms trailing), keep the in-memory update synchronous.

### L2 · "New resume" is pre-populated with the entire seed CV

`DocumentStore.create` uses `SeedData.resume()` for a brand-new resume instead
of the existing-but-unused `emptyResume()` helper. New *letters* correctly
start near-empty. Product call on whether that's intended.

### L3 · `TextEditingController` leak in the rename dialog

`_promptText` (`ui/home/home_screen.dart`) news a controller per rename and
never disposes it.

### L4 · PDF preview ignores the page-format selector

`PreviewScreen` hardcodes `PdfPageFormat.a4` in the template regardless of the
toolbar's format selector.

### L5 · LaTeX editor edits are a scratch buffer with no save and no warning

Nothing tells the user that edits in `LatexEditorScreen` aren't saved back to
the document.

### L6 · Empty "References" section renders inconsistently across formats

PDF hides the section when empty; `.tex`/DOCX/text always emit something.

### L7 · Export temp filenames can collide or degenerate

`ExportService.writeToFile`'s slugify can produce empty/colliding filenames for
non-ASCII or near-identical titles.

### L10 · No `FlutterError` / zone error handling, fire-and-forget bootstrap

`main.dart`'s store `.load()` calls aren't awaited and there's no
`runZonedGuarded`/`FlutterError.onError` hook.

### L11 · `DocumentRepository` scans the directory twice on startup and uses sync I/O

`isEmpty()` then `loadAll()` both run `dir.listSync()`.

### L12 · `pdf_combiner_screen` re-reads the merged file on every rebuild

`_readBytes` is the `PdfPreview.build` callback, so any `setState` re-reads the
whole combined PDF.

---

## Info / observations (original pass)

- **I1 — Widget test coverage was zero; now partial.** Superseded — see
  **Fresh findings → Test coverage** below for the current, more granular
  picture.
- **I2 — Model equality.** No `==`/`hashCode` on the data models. Still true,
  still low-impact.
- **I3 — Release APK is debug-signed.** Still true; `TODO`s remain in
  `android/app/build.gradle.kts`.
- **I4 — `analysis_options.yaml` is the stock template.** Still true.
- **I5 — `assets/fonts/` not listed under `assets:`.** Still true, still works.
- **I6 — `.tex` templates load `fontawesome5`** vs. docs saying "Font Awesome
  6". Still a doc-only mismatch.
- **I7 — misplaced `// ignore: use_build_context_synchronously`** in
  `settings_screen.dart`. Still present.
- **I8 — `com.vinald.*` application id / bundle id** left as-is (developer
  namespace, not personal data — see C3 below for what *was* addressed).
- **I9 — `devtools_options.yaml`** — see C4 below; it needed fixing twice.

---

## Fresh findings — September 2026 full review

### Code quality

**C1 · `cupertino_icons` is an unused dependency**

`pubspec.yaml` declares `cupertino_icons: ^1.0.8`; nothing in `lib/` imports
`CupertinoIcons` or `package:cupertino_icons`. Leftover from the Flutter
project template (the app is Material 3 throughout, including its icons).
Harmless but adds a dependency and a line to review for no reason.

**Fix:** remove the line from `pubspec.yaml`.

**C2 · `main.dart`'s bootstrap is unchanged since the original review — L10 still open**

Restating for visibility since this review widened scope rather than because
it's new: no crash telemetry seam exists between `ensureInitialized()` and
`runApp()`. Low priority for a fully local app, but worth doing before any
crash-reporting integration.

**C3 · `com.vinald.*` application id — deliberately not renamed, still worth a decision**

Both `android/app/build.gradle.kts` (`applicationId`) and
`ios/Runner.xcodeproj/project.pbxproj` (`PRODUCT_BUNDLE_IDENTIFIER`) still read
`com.vinald.resume_generator` / `com.vinald.resumeGenerator`, unrelated to the
display-name rename to "Resumate" in PR #5 (deliberately scoped out — see that
PR's description and I8 above). This is a developer namespace, not personal
data, so it's not a privacy issue as-is. It does mean: (a) anyone else building
this repo needs their own applicationId/bundle id to publish to a store under
their own account, and (b) the identifier doesn't match the product name
anymore, which reads oddly in `flutter doctor`/build output and any future Play
Console / App Store Connect listing. Worth a deliberate rename (Kotlin package
directory move + Xcode project edit) the next time either platform's listing
is actually set up — not urgent before then.

**C4 · `devtools_options.yaml` was tracked in git despite being gitignored**

The `.gitignore` fix in PR #3 added `devtools_options.yaml` to the ignore list,
but the file had already been picked up by an earlier `git add -A` (PR #2, before
the ignore rule existed) — adding a pattern to `.gitignore` doesn't untrack a
file already in the index. It stayed tracked and kept showing up as a diff in
every subsequent PR ("1 uncommitted change" warnings throughout this session).

**Fixed this pass:** `git rm --cached devtools_options.yaml` — the file stays
on disk (still useful locally) but is no longer tracked, and the existing
`.gitignore` entry now actually takes effect.

### Dependencies & toolchain

**D1 · Several direct dependencies are multiple major versions behind**

`flutter pub outdated`:

| Package | Current | Latest |
| --- | --- | --- |
| `pdf_combiner` | 3.4.0 | 6.2.2 |
| `file_picker` | 8.3.7 | 12.3.0 |
| `share_plus` | 10.1.4 | 13.3.0 |
| `archive` | 3.6.1 | 4.2.0 |
| `printing` | 5.14.3 | 5.15.0 |
| `pdf` | 3.12.0 | 3.13.0 |
| `intl` | 0.19.0 | 0.20.3 |

`pdf_combiner` is the one most worth a deliberate upgrade: the
`dependency_overrides: file_magic_number: 1.2.0` pin in `pubspec.yaml` exists
*specifically* because `pdf_combiner` 3.4.0 depends on an old
`file_magic_number` API. Later `pdf_combiner` releases likely moved past that
dependency entirely, which would let the override — and the maintenance risk it
carries (it silently pins a transitive package below what anything else in the
tree wants) — be dropped. `file_picker`/`share_plus` are 3–4 majors behind;
each major likely has API changes worth reading through before bumping, so
treat as a deliberate, tested upgrade PR, not a drive-by `pub upgrade
--major-versions`.

**D2 · Flutter's configured JDK can silently break every Android build, independent of `JAVA_HOME`**

Not a code issue, but worth recording since it cost real time this session and
will cost a future contributor the same: `flutter config --jdk-dir` (stored in
Flutter's own tool state, not the repo) takes priority over the `JAVA_HOME`
environment variable. If it's set (or a stale value lingers after a JDK is
uninstalled), exporting `JAVA_HOME` in your shell — the README's documented
fix — has **no effect**, and the error message ("JAVA_HOME is set to an invalid
directory: ...") looks exactly like the `JAVA_HOME`-not-set case, sending you
down the wrong path. Compounding this: killing a `flutter run`/`flutter test`
process with `kill -9` can leave a Gradle daemon (and a separate Kotlin compile
daemon) alive in the background, pinned to whichever JDK launched it — a
_correct_ `flutter config --jdk-dir` fix can still fail against a stale daemon
with a `VerifyError` from mixed Kotlin-runtime classpaths until that daemon is
also killed (`ps aux | grep -E "GradleDaemon|KotlinCompileDaemon"`).

**Fix:** document this explicitly in the README's build section (currently
only mentions `JAVA_HOME`), e.g.: *"If `flutter build apk`/`flutter run` fails
with a JDK error even after `export JAVA_HOME=...`, also run `flutter config
--jdk-dir=$JAVA_HOME` and check for stale `GradleDaemon`/`KotlinCompileDaemon`
processes pinned to a different JDK."*

**D3 · CI doesn't build the app, only analyzes and unit-tests it**

`.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` — it would
not have caught the Kotlin/JDK-driven build breakage above (that's
environment-specific, not a real code regression), but it also wouldn't catch
a genuine Android build break (a manifest error, a Gradle config typo, a
plugin version conflict) before it reaches `main`. Consider adding a `flutter
build apk --debug` step (skip the release/signing path — debug build is
sufficient to prove the toolchain resolves and compiles).

**D4 · CI actions pinned to major-version tags, not SHAs**

`actions/checkout@v4` and `subosito/flutter-action@v2` — standard, low-risk
practice for most repos (not pinning to a commit SHA), but worth a mention
since it's the kind of thing that changes if this repo's threat model changes
(e.g. if it starts accepting external PRs that trigger CI with secrets).

### Security review

The app has a small attack surface: no network calls anywhere in `lib/` (grep
confirmed — the only `http://`/`https://` strings are XML namespace URIs in the
generated DOCX and the pdf.js CDN URL used only by the web build's PDF
preview), no authentication, no backend, and only the plugins needed for local
file/image picking and sharing.

- **S1 (Info) — Documents are stored unencrypted in app-private storage.**
  `DocumentRepository`/`SettingsRepository` write plain JSON to the platform's
  app documents directory via `path_provider`. That directory is sandboxed by
  the OS (not readable by other apps without root/jailbreak), which matches
  the security model of virtually every local-first mobile app — not a
  vulnerability. Worth noting explicitly because resumes and letters contain
  real PII (name, phone, email, sometimes references' contact details): if a
  user's threat model includes "someone else has physical access to my
  unlocked phone," that's a device-level concern, not something this app's
  storage choice changes.
- **S2 (Info) — No explicit `<uses-permission>` in `AndroidManifest.xml`.**
  Confirmed nothing is missing: `image_picker`/`file_picker`/`share_plus`
  merge their own required permissions into the final manifest via their AARs
  (standard Android library manifest merging), so the app manifest itself
  correctly declares none directly.
- **S3 (Info) — Web build loads pdf.js from `cdnjs.cloudflare.com` at runtime
  with no Subresource Integrity hash.** This is the `printing` package's own
  behavior (`web/index.html` only sets the version/base-URL it should fetch),
  not something the app controls. Low practical risk since the web target is
  explicitly "quick previews on desktop" (README), not the shipped product,
  but worth knowing if the web build is ever taken more seriously.
- **S4 (confirmed clean) — no hardcoded secrets, API keys, or tokens anywhere
  in `lib/`** (checked via pattern search for `api_key`/`secret`/`token`/
  `password` — the only hits were unrelated `{{token}}` placeholder UI text).
- **S5 (confirmed clean) — no path-traversal / zip-slip surface.** `archive`
  is used only to *build* the DOCX zip from in-memory strings, never to
  extract an untrusted archive; `pdf_combiner` merges only user-selected local
  files (via the system file picker), never a remote or attacker-controlled
  path.
- Ties back to **M3** above: the one real input-validation gap (an unvalidated
  image file trusted to be PNG/JPEG) is a robustness bug, not a security one —
  worst case is a crash/broken export, not code execution or data exposure.

### Test coverage gaps

32 tests now cover: model JSON round-trips (incl. `tutorialSeen`), repository
CRUD, seed-data shape, the LaTeX engine + escaping, DOCX structure +
placeholder resolution + XML escaping, plain-text/Markdown output, raw PDF
rendering, `StringListEditor` reorder/insert/remove, and the home screen's
first-launch tutorial prompt (4 tests, with one assertion intentionally
descoped — see that test file's header comment).

**Screens with zero test coverage:**

| Screen | What's untested |
| --- | --- |
| `ResumeEditorScreen` / `LetterEditorScreen` | Autosave-on-pop, the dirty-state FAB, the full add/edit/reorder/delete flow end-to-end (only the underlying `StringListEditor` is unit-tested) |
| `SettingsScreen` | Every control — accent colour, body font, margin/spacing sliders, default contact |
| `LatexEditorScreen` | Loading, copy, share, the token reference sheet |
| `PreviewScreen` | Renders at all, reacts to settings changes |
| `PdfCombinerScreen` | Pick, reorder, combine, error path (< 2 files) |
| `ExportSheet` | Format selection → `ExportService.share` wiring, the error snackbar path |
| `SignaturePicker` | Pick, replace, remove — this is also the screen with the open M3 robustness gap, so it's the highest-value screen to add coverage to |
| `contact_section.dart` | Shared by 3 screens, no direct test |

**Fix:** not all of these need coverage before the next release, but
`SignaturePicker` (feeds directly into M3) and the resume/letter editor's
save/dirty-state flow (the app's core loop) are the two highest-value gaps.
`test/home_screen_tutorial_test.dart`'s header comment documents two real
environment gotchas for writing more of these (`dart:io` in `testWidgets`
bodies, and real I/O triggered as a side effect of pumping) — worth reading
before adding to this list.

---

## Suggested fix batches

| Batch | Contents |
| --- | --- |
| Done | H1, M1, M2 (email case), L8, L9, C4 |
| Quick wins | C1 (remove unused dep), D2/D4 (docs-only) |
| Needs a product/dependency call | M3, L1, L2, L4, L5, L6, L7 |
| Hardening | L3, L10, L11, L12, D1 (dependency majors), D3 (CI build step) |
| Coverage | `SignaturePicker`, resume/letter editor save flow, then the rest of the table above |
