import 'package:flutter/material.dart';

/// One step of the in-app walkthrough. Mirrors `TUTORIAL.md` in the repo,
/// condensed for on-screen reading — keep the two roughly in sync.
class _TutorialStep {
  const _TutorialStep(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _steps = <_TutorialStep>[
  _TutorialStep(
    Icons.auto_awesome_outlined,
    'Start from a sample',
    'Resumate opens with a placeholder resume and two placeholder letters '
        'already in place, so there\'s something to look at immediately. '
        'Rename, edit, or delete them like any other document.',
  ),
  _TutorialStep(
    Icons.edit_note_outlined,
    'Edit in structured sections',
    'Open a resume to fill in Contact, Summary, Employment history, Skills, '
        'Education, Projects and References. Tap + to add an entry; use the '
        '↑ / ↓ / 🗑 controls under an entry to reorder or remove it. Changes '
        'save automatically when you leave the screen.',
  ),
  _TutorialStep(
    Icons.visibility_outlined,
    'Preview before you export',
    'The eye icon in the editor renders the actual PDF — the same renderer '
        'used for export — so what you see is what you\'ll get.',
  ),
  _TutorialStep(
    Icons.draw_outlined,
    'Add a signature',
    'In a letter\'s Sign-off section, add a signature image from your '
        'gallery. It\'s saved once and reused on every letter\'s PDF, and '
        'shipped alongside .tex exports as signature.png.',
  ),
  _TutorialStep(
    Icons.short_text_outlined,
    'Fill in letter placeholders',
    'Any {{token}} in a letter — by default {{position}} and {{company}} — '
        'gets its own field under Placeholders. An unfilled one renders as '
        '[position] rather than vanishing, so it\'s obvious if you missed one.',
  ),
  _TutorialStep(
    Icons.ios_share_outlined,
    'Export or share',
    'The share icon offers PDF, Word (DOCX), LaTeX (.tex), plain text, or '
        'Markdown. This opens the system share sheet — save the file from '
        'there if you just want to keep it.',
  ),
  _TutorialStep(
    Icons.code_outlined,
    'See the LaTeX source',
    'The </> icon shows the real .tex your document produces, generated '
        'live into the bundled templates — handy for pasting into Overleaf. '
        'Edits made on that screen are a scratch buffer and aren\'t saved '
        'back into the document.',
  ),
  _TutorialStep(
    Icons.tune_outlined,
    'Make it yours in Settings',
    'The gear icon on the home screen sets your default contact, accent '
        'colour, body font, page margin, line spacing, and signature — '
        'applied to every new document.',
  ),
  _TutorialStep(
    Icons.merge_type_outlined,
    'Combine PDFs',
    'The merge icon on the home screen combines several PDFs — reorder them, '
        'then Combine. Handy for stapling a resume and cover letter together.',
  ),
];

/// The in-app walkthrough, opened from the home screen's help icon or shown
/// once automatically on first launch. See also `TUTORIAL.md` in the repo.
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How Resumate works')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
        itemCount: _steps.length,
        itemBuilder: (context, i) {
          final step = _steps[i];
          final colorScheme = Theme.of(context).colorScheme;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: Icon(step.icon, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(step.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
