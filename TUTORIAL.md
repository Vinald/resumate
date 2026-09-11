# Getting started with Resumate

A first-run walkthrough. Everything here works offline, on-device — there's no
account and nothing leaves your phone unless you tap Share.

## 1. First launch

Resumate opens with three sample documents already in place, so there's
something to look at immediately:

- **My Resume** — a full placeholder CV ("Alex Doe").
- **Cover Letter** and **Application Letter** — placeholder letters with
  `{{position}}` / `{{company}}` fields left blank.

The **Resumes** / **Letters** tabs at the top switch between them.

## 2. Make the resume yours

Tap **My Resume** to open the editor. Every section is a form:

1. **Contact** — name, title, phone, email, portfolio/GitHub/LinkedIn.
2. **Summary** — the paragraph under your name.
3. **Employment history** — tap **+** to add a job; each entry has role,
   organization, dates and a bulleted list. Use the ↑ / ↓ / 🗑 controls under
   an entry to reorder or remove it.
4. **Technical skills** — categories (e.g. "Frontend") with a comma-separated
   item list.
5. **Soft skills**, **Education**, **Projects** — same add / reorder / delete
   pattern.
6. **References** — toggle **Available on request** off to list named
   references instead of the note.

Changes save automatically when you leave the screen (there's also a **Save**
button that appears once you've made an edit). Nothing is written until then,
so backing out with unsaved changes still saves — there's no silent discard.

## 3. Preview

Tap the eye icon (👁) in the editor's app bar. This renders the actual PDF —
the same renderer used for export — so what you see is what you'll get.

## 4. Add a signature (letters)

Open a letter, scroll to **Sign-off**, and tap **Add signature**. Pick an
image from your gallery; it's saved once in Settings and reused on every
letter's PDF and, for `.tex` export, shipped alongside the source as
`signature.png`.

## 5. Fill in a letter's placeholders

Open **Cover Letter** or **Application Letter**. Any `{{token}}` in the body —
by default `{{position}}` and `{{company}}` — gets its own field at the top of
the editor, under **Placeholders**. Fill those in before exporting; an
unfilled placeholder renders as `[position]` rather than disappearing, so it's
obvious in the output if you missed one.

## 6. Export or share

Tap the share icon (⬆) in any editor and pick a format:

| Format | Good for |
| --- | --- |
| **PDF** | Sending as-is, printing. |
| **Word (DOCX)** | Further editing in Word/Google Docs. |
| **LaTeX (.tex)** | Pasting into Overleaf for pixel-exact control. |
| **Plain text** | Copy-pasting into a web form. |
| **Markdown** | READMEs, notes apps, static sites. |

This opens the system share sheet, so "export" and "share" are the same
action — save it from there (e.g. "Save to Files") if you just want the file.

## 7. The LaTeX source view

Tap the `</>` icon to see the actual `.tex` that export produces, generated
live from your data into the bundled templates
(`assets/templates/*.tex`). **Copy** and **Share .tex** work from this screen;
edits you make here are a scratch buffer for a one-off tweak — they aren't
saved back into the document, so they won't survive re-opening the editor.

## 8. Settings

The gear icon on the home screen holds app-wide defaults:

- **Contact** — pre-fills new documents.
- **Accent colour** — the blue headings/rules throughout (`#0000FF` by
  default, to match the original LaTeX template).
- **Body font** — EB Garamond (the default, matching LaTeX), Helvetica, or
  Times.
- **Page margin** / **Line spacing**.
- **Signature** — same picker as in the letter editor; one signature is
  shared by every letter.

## 9. Combine PDFs

The merge icon (⛙) on the home screen opens the PDF combiner: add two or more
PDFs, drag to reorder, then **Combine**. Handy for stapling a resume and a
cover letter into one file before sending.

## 10. Starting over with a blank slate

The three sample documents are placeholder content, not special — rename,
edit, or delete them like anything else. To add a new one from scratch, tap
**New** on the home screen and pick a type.

---

Ran into something that doesn't work as described? Check the **Known
limitations** and **Support** sections in [`README.md`](README.md).
