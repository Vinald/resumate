import 'package:flutter/material.dart';

/// A titled card that groups related form fields.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A single-line / multi-line text field wired to a value + onChanged.
class EditorField extends StatelessWidget {
  const EditorField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.hintText,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        maxLines: maxLines,
        minLines: 1,
        decoration: InputDecoration(labelText: label, hintText: hintText),
      ),
    );
  }
}

/// Editor for an ordered list of short strings (bullets, skill items, …).
class StringListEditor extends StatelessWidget {
  const StringListEditor({
    super.key,
    required this.label,
    required this.values,
    required this.onChanged,
    this.itemHint = 'Item',
    this.multiline = false,
  });

  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String itemHint;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (var i = 0; i < values.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('$label-$i-${values.length}'),
                    initialValue: values[i],
                    minLines: 1,
                    maxLines: multiline ? 4 : 1,
                    decoration: InputDecoration(hintText: itemHint),
                    onChanged: (v) {
                      final next = [...values];
                      next[i] = v;
                      onChanged(next);
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed:
                      i == 0
                          ? null
                          : () {
                            final next = [...values];
                            final item = next.removeAt(i);
                            next.insert(i - 1, item);
                            onChanged(next);
                          },
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    final next = [...values]..removeAt(i);
                    onChanged(next);
                  },
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => onChanged([...values, '']),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${itemHint.toLowerCase()}'),
          ),
        ),
      ],
    );
  }
}

/// Row of reorder / delete controls for a list entry.
class EntryControls extends StatelessWidget {
  const EntryControls({
    super.key,
    required this.index,
    required this.count,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final int index;
  final int count;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_upward, size: 18),
          onPressed: index == 0 ? null : onMoveUp,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward, size: 18),
          onPressed: index == count - 1 ? null : onMoveDown,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
