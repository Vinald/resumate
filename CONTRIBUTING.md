# Contributing

## Setup

```sh
flutter pub get
flutter run           # device or emulator
flutter run -d chrome # quick desktop preview (no persistence, no native PDF preview)
```

Flutter `stable` `3.38.5` (matches CI). Android release builds need JDK 21 (see
README).

## Before you push

```sh
flutter analyze   # must be clean
flutter test      # must be green
```

CI runs exactly these on every PR.

## Conventions

- **Commits:** one-line imperative subject ("Add signature image to letter PDF").
  No trailers.
- **Branches:** `fix/…`, `chore/…`, `docs/…`, `feat/…`. One logical change per
  branch / PR.
- **Dart style:** the repo default (`flutter_lints`). Keep trailing commas so the
  formatter lays widgets out vertically. Run `dart format .` if in doubt.
- Models stay plain: constructor with defaults, `toJson` / `fromJson` (defensive),
  `copy` / `copyWith`. If you add a field, update all four plus any affected
  test in `test/models_serialization_test.dart`.
- Output modules (`render/`, `latex/`, `export/`) must stay pure — take
  `GeneratedDocument` + `AppSettings`, return bytes / string, no store access.

## Where things live

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). Common tasks:

| Task | Start here |
| --- | --- |
| New export format | `export/export_service.dart` (`ExportFormat` enum + `switch`) |
| New PDF template | implement `render/*_template.dart`, register in `template_registry.dart` |
| New LaTeX token | `latex/latex_engine.dart` (the token map) + `latex/tokens.dart` (the doc) + the `.tex` files in `assets/templates/` |
| New resume/letter field | `models/` → the editor screen → the four renderers (`classic_blue_template`, `classic_letter_template`, `latex_engine`, `docx_export`, `text_export`) |
| Change the sample CV | `lib/data/seed_data.dart` (keep it generic placeholder content) |

## Known issues

[`REVIEW.md`](REVIEW.md) tracks known bugs with severity and suggested fixes.
Picking one off is a good first contribution.

## Tests

Add a test with any behaviour change. Repositories and the LaTeX engine have
injection seams (`baseDir:`, `loadAsset:`). There is no widget-test coverage yet
— adding some (starting with the resume editor reorder path, REVIEW.md M1) is
welcome.
