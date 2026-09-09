# Architecture

This is a longer companion to the "Architecture" section of the README. It walks
each layer in the order data flows through it.

## Layers at a glance

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

Nothing in the output modules touches the stores or the repositories. They take a
`GeneratedDocument` and an `AppSettings` and return bytes or a string. The only
I/O they do is `rootBundle` reads of the bundled `.tex` templates and TTFs, and
reading the signature image file by path.

## Models (`lib/models/`)

Plain mutable classes. Every one has:

- a positional/named constructor with defaults (so a "blank" instance is valid),
- `toJson()` / `fromJson()` — `fromJson` is defensive: every field has a
  fallback, unknown enum values fall back to the first case, missing lists become
  empty lists,
- `copy()` / `copyWith()` — deep copies for the "edit a copy, commit on save"
  pattern.

`GeneratedDocument` holds metadata plus **exactly one** of `resume` / `letter`
(nullable, chosen by `type`). `toJson` only serialises the non-null one.

`LetterData` owns the `{{placeholder}}` mechanism:

- `placeholderNames` — scans `companyName`, `companyAddress`, `salutation`,
  `recipientDept` and every body paragraph for `{{token}}` and returns the
  distinct names. The letter editor renders one field per name.
- `resolve(text)` — substitutes from the `placeholders` map; an unset/empty value
  renders as `[name]` so nothing silently disappears.

`AppSettings.accentColor` is a single ARGB int. `accentRgb` splits it into
`"R, G, B"` for the `<<ACCENT_RGB>>` LaTeX token.

## Persistence (`lib/data/`)

`DocumentRepository` — one `<uuid>.json` per document under a `documents/`
subdirectory of the app documents directory (`path_provider`). `loadAll` skips
files that fail to parse rather than failing the whole load. A `baseDir` can be
injected for tests.

`SettingsRepository` — a single `settings.json`. Missing or corrupt file →
`AppSettings()` defaults.

`DocumentStore` (`ChangeNotifier`):

- `load()` — if the repo is empty, writes `SeedData.initialDocuments()`, then
  loads all. **If any storage call throws** (e.g. web, where `path_provider` has
  no backing dir) it logs and runs from an in-memory copy of the seed data — the
  app still works, it just doesn't persist.
- `save` / `delete` / `create` / `duplicate` — mutate the in-memory list, call
  the repo (swallowing storage errors), `notifyListeners`, keep the list sorted
  by `updatedAt` desc.

`SettingsStore` is the same shape over a single `AppSettings`.

Both stores are created in `main.dart` and their `load()` is started but **not
awaited** — the UI shows a spinner while `loading` is true.

## Rendering (`lib/render/`)

`PdfTheme.create(settings)` loads the four EB Garamond faces (or Helvetica /
Times) and the two Font Awesome TTFs **once** (static cache) and builds a
`pw.ThemeData`. It also carries the accent `PdfColor`, the margin in points and
the line spacing.

`ClassicBlueTemplate` / `ClassicLetterTemplate` build a `pw.MultiPage` (A4,
margins from settings). Section visibility is data-driven: an empty list means
no heading. `PdfComponents` holds the shared bits — the centred uppercase accent
heading + rule, the `✓` bullet (Font Awesome check glyph in the accent colour),
the icon+text pairs on the contact line, and `UrlLink` wrappers.

`buildDocumentPdf(doc, settings)` picks the template from
`TemplateRegistry.resume(doc.templateId)` for resumes, and always
`classic_letter` for letters, reading the signature bytes from disk first if a
path is set and the file exists.

## LaTeX (`lib/latex/`)

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

> Known gap (REVIEW.md M2): URL and email tokens are **not** escaped and the
> email is also used as visible link text, so `_ # %` in those fields break the
> `.tex`.

## Export (`lib/export/`)

`ExportService.writeToFile(doc, settings, format)` slugifies the title, writes to
a temp file, and dispatches on `ExportFormat`. `share()` additionally attaches
`signature.png` next to a letter `.tex` so it drops straight into Overleaf.

`DocxExport` builds the five-part OOXML zip by hand
(`[Content_Types].xml`, `_rels/.rels`, `word/_rels/document.xml.rels`,
`word/styles.xml`, `word/document.xml`) with `archive`. Layout is intentionally
plain — headings, bold runs, literal `✓` bullets — so it opens clean and stays
editable in Word. XML text is escaped via `_x()`.

`TextExport` produces plain text (UPPERCASE headings) or Markdown (`#` headings),
sharing the section walk.

## UI (`lib/ui/`)

`provider` supplies `DocumentStore` and `SettingsStore` from the root.

`HomeScreen` — `DefaultTabController` (Resumes / Letters), a FAB that opens a
type picker then the matching editor, per-row popup menu (rename / duplicate /
delete with confirm).

`ResumeEditorScreen` / `LetterEditorScreen` — `StatefulWidget`s holding a
`.copy()` of the payload and a `_dirty` flag. `PopScope` autosaves on back. Every
`onChanged` runs through `_edit(() {...})` which mutates the copy and
`setState`s. List sections use a private `_EntryFrame` with move-up/down/delete.

`contact_section.dart` is shared by both editors and the settings screen.

`LatexEditorScreen` — generates the `.tex` into a `TextEditingController` on open.
Copy / Share use the (possibly edited) buffer; there is no save-back.

`SettingsScreen` — writes through `SettingsStore.update` on every change
(see REVIEW.md L1 about the write frequency).

`PdfCombinerScreen` — `ReorderableListView` of picked PDFs, `_combine()` calls
`PdfCombinerService.merge`, shows a `PdfPreview` of the result and a share
action.

## Testing seams

- `DocumentRepository(baseDir:)` / `SettingsRepository(baseDir:)` — temp dir.
- `LatexEngine(loadAsset:)` — load templates from disk instead of `rootBundle`.
- Output modules are pure, so most tests are `SeedData → module → assert on the
  string/bytes`.
