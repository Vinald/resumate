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
///
/// Backed by one [TextEditingController] per row so that reordering a row keeps
/// its text with it (a plain `initialValue` field would show the previous row's
/// text after a move — see REVIEW.md M1).
class StringListEditor extends StatefulWidget {
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
  State<StringListEditor> createState() => _StringListEditorState();
}

class _StringListEditorState extends State<StringListEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.values.map(_controller).toList();
  }

  @override
  void didUpdateWidget(StringListEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Structural edits made through this widget keep [_controllers] and
    // widget.values in lock-step already; only resync when the parent replaced
    // the list out from under us (load, undo, section reset).
    if (!_inSync()) {
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers = widget.values.map(_controller).toList();
    }
  }

  TextEditingController _controller(String text) =>
      TextEditingController(text: text);

  bool _inSync() {
    if (widget.values.length != _controllers.length) return false;
    for (var i = 0; i < widget.values.length; i++) {
      if (_controllers[i].text != widget.values[i]) return false;
    }
    return true;
  }

  void _emit() =>
      widget.onChanged(_controllers.map((c) => c.text).toList(growable: false));

  void _add() {
    setState(() => _controllers.add(_controller('')));
    _emit();
  }

  void _removeAt(int i) {
    setState(() => _controllers.removeAt(i).dispose());
    _emit();
  }

  void _moveUp(int i) {
    if (i == 0) return;
    setState(() {
      final c = _controllers.removeAt(i);
      _controllers.insert(i - 1, c);
    });
    _emit();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (var i = 0; i < _controllers.length; i++)
          Padding(
            key: ObjectKey(_controllers[i]),
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[i],
                    minLines: 1,
                    maxLines: widget.multiline ? 4 : 1,
                    decoration: InputDecoration(hintText: widget.itemHint),
                    onChanged: (_) => _emit(),
                  ),
                ),
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: i == 0 ? null : () => _moveUp(i),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => _removeAt(i),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${widget.itemHint.toLowerCase()}'),
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
