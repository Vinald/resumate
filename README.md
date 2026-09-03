# Resume Generator

A Flutter app for phones (Android + iOS) that replaces the Overleaf workflow for building
resumes, cover letters and application letters.

## What it does

- Edit resume and letter content through structured forms on your phone
- Render a PDF natively, styled to match the blue-heading LaTeX template
- Export to **PDF**, **DOCX (Word)**, **plain text**, **Markdown** and **LaTeX (`.tex`)**
- Fill in the bundled `.tex` templates with your data and export the source for Overleaf
- Combine several PDFs into one
- Everything is stored locally on the device

## Getting started

```sh
flutter pub get
flutter run
```

First-time toolchain setup:

- Android: `flutter doctor --android-licenses` and accept
- iOS: `sudo gem install cocoapods` (or `brew install cocoapods`), then `cd ios && pod install`
- Web (handy for quick previews on desktop): `flutter run -d chrome`

## Project layout

| Path | Purpose |
| --- | --- |
| `lib/models/` | data model (resume, letter, document meta, settings) |
| `lib/data/` | local JSON persistence + seed data |
| `lib/render/` | PDF templates (Classic Blue is the default) |
| `lib/latex/` | `.tex` token-fill engine and token catalogue |
| `lib/export/` | PDF / DOCX / text / Markdown / `.tex` exporters |
| `lib/pdf_tools/` | PDF combiner |
| `lib/ui/` | screens |
| `assets/templates/` | the `.tex` source templates with `<<TOKENS>>` |
| `assets/fonts/` | EB Garamond (body) + Font Awesome (contact icons) |

## Testing

```sh
flutter analyze
flutter test
```

Covered: model serialization, local repository CRUD, seed-data round-trips, the
LaTeX token engine, DOCX zip structure, plain-text / Markdown output, and native
PDF rendering.

## Notes

- **Storage** is local per device (`path_provider`). If storage is unavailable
  (e.g. running on web for a quick look), the app runs from in-memory seed data.
- **Web PDF preview** relies on `printing`'s pdf.js integration; the in-app
  preview is intended for Android / iOS, where it uses the native renderer.
- The `.tex` export path fills the real templates in `assets/templates/` and is
  the way to get pixel-exact Overleaf output.
