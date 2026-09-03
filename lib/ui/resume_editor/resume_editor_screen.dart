import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/document_store.dart';
import '../../models/document.dart';
import '../../models/resume.dart';
import '../export/export_sheet.dart';
import '../latex_editor/latex_editor_screen.dart';
import '../preview/preview_screen.dart';
import '../widgets/editor_widgets.dart';
import 'contact_section.dart';

class ResumeEditorScreen extends StatefulWidget {
  const ResumeEditorScreen({super.key, required this.documentId});

  final String documentId;

  @override
  State<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends State<ResumeEditorScreen> {
  late GeneratedDocument _doc;
  late ResumeData _data;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _doc = context.read<DocumentStore>().byId(widget.documentId)!;
    _data = _doc.resume!.copy();
  }

  void _edit(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  Future<void> _save() async {
    _doc.resume = _data.copy();
    await context.read<DocumentStore>().save(_doc);
    setState(() => _dirty = false);
  }

  static void _reorder<T>(List<T> list, int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= list.length) return;
    final item = list.removeAt(index);
    list.insert(target, item);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _save();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_doc.title),
          actions: [
            IconButton(
              tooltip: 'LaTeX source',
              icon: const Icon(Icons.code),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LatexEditorScreen(documentId: _doc.id),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Preview',
              icon: const Icon(Icons.visibility),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PreviewScreen(documentId: _doc.id),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Export',
              icon: const Icon(Icons.ios_share),
              onPressed: () async {
                await _save();
                if (!context.mounted) return;
                showExportSheet(context, _doc.id);
              },
            ),
          ],
        ),
        floatingActionButton:
            _dirty
                ? FloatingActionButton.extended(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                )
                : null,
        body: ListView(
          children: [
            ContactSection(
              contact: _data.contact,
              onChanged: (c) => _edit(() => _data.contact = c),
            ),
            SectionCard(
              title: 'Summary',
              children: [
                EditorField(
                  label: 'Professional summary',
                  value: _data.summary,
                  maxLines: 8,
                  onChanged: (v) => _edit(() => _data.summary = v),
                ),
              ],
            ),
            _ExperienceSection(data: _data, edit: _edit),
            _SkillsSection(data: _data, edit: _edit),
            SectionCard(
              title: 'Soft skills',
              children: [
                StringListEditor(
                  label: 'Soft skills',
                  values: _data.softSkills,
                  itemHint: 'Skill',
                  onChanged: (v) => _edit(() => _data.softSkills = v),
                ),
              ],
            ),
            _EducationSection(data: _data, edit: _edit),
            _ProjectsSection(data: _data, edit: _edit),
            _ReferencesSection(data: _data, edit: _edit),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({required this.data, required this.edit});

  final ResumeData data;
  final void Function(VoidCallback) edit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Employment history',
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => edit(() => data.experience.add(ExperienceEntry())),
      ),
      children: [
        for (var i = 0; i < data.experience.length; i++)
          _EntryFrame(
            index: i,
            count: data.experience.length,
            onMoveUp: () => edit(
              () => _ResumeEditorScreenState._reorder(data.experience, i, -1),
            ),
            onMoveDown: () => edit(
              () => _ResumeEditorScreenState._reorder(data.experience, i, 1),
            ),
            onDelete: () => edit(() => data.experience.removeAt(i)),
            child: Column(
              children: [
                EditorField(
                  label: 'Role',
                  value: data.experience[i].role,
                  onChanged: (v) => edit(() => data.experience[i].role = v),
                ),
                EditorField(
                  label: 'Organization',
                  value: data.experience[i].organization,
                  onChanged:
                      (v) => edit(() => data.experience[i].organization = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: EditorField(
                        label: 'Start',
                        value: data.experience[i].startDate,
                        onChanged:
                            (v) => edit(() => data.experience[i].startDate = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: EditorField(
                        label: 'End',
                        value: data.experience[i].endDate,
                        onChanged:
                            (v) => edit(() => data.experience[i].endDate = v),
                      ),
                    ),
                  ],
                ),
                StringListEditor(
                  label: 'Bullets',
                  values: data.experience[i].bullets,
                  itemHint: 'Bullet',
                  multiline: true,
                  onChanged: (v) => edit(() => data.experience[i].bullets = v),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.data, required this.edit});

  final ResumeData data;
  final void Function(VoidCallback) edit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Technical skills',
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => edit(() => data.skills.add(SkillCategory())),
      ),
      children: [
        for (var i = 0; i < data.skills.length; i++)
          _EntryFrame(
            index: i,
            count: data.skills.length,
            onMoveUp:
                () => edit(() => _ResumeEditorScreenState._reorder(data.skills, i, -1)),
            onMoveDown:
                () => edit(() => _ResumeEditorScreenState._reorder(data.skills, i, 1)),
            onDelete: () => edit(() => data.skills.removeAt(i)),
            child: Column(
              children: [
                EditorField(
                  label: 'Category',
                  value: data.skills[i].label,
                  onChanged: (v) => edit(() => data.skills[i].label = v),
                ),
                EditorField(
                  label: 'Items (comma separated)',
                  value: data.skills[i].items.join(', '),
                  maxLines: 2,
                  onChanged:
                      (v) => edit(
                        () =>
                            data.skills[i].items =
                                _splitCsv(v),
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.data, required this.edit});

  final ResumeData data;
  final void Function(VoidCallback) edit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Education',
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => edit(() => data.education.add(EducationEntry())),
      ),
      children: [
        for (var i = 0; i < data.education.length; i++)
          _EntryFrame(
            index: i,
            count: data.education.length,
            onMoveUp: () => edit(
              () => _ResumeEditorScreenState._reorder(data.education, i, -1),
            ),
            onMoveDown: () => edit(
              () => _ResumeEditorScreenState._reorder(data.education, i, 1),
            ),
            onDelete: () => edit(() => data.education.removeAt(i)),
            child: Column(
              children: [
                EditorField(
                  label: 'Qualification',
                  value: data.education[i].qualification,
                  onChanged:
                      (v) => edit(() => data.education[i].qualification = v),
                ),
                EditorField(
                  label: 'Institution',
                  value: data.education[i].institution,
                  onChanged:
                      (v) => edit(() => data.education[i].institution = v),
                ),
                EditorField(
                  label: 'Dates (optional)',
                  value: data.education[i].dates,
                  onChanged: (v) => edit(() => data.education[i].dates = v),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.data, required this.edit});

  final ResumeData data;
  final void Function(VoidCallback) edit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Projects',
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => edit(() => data.projects.add(ProjectEntry())),
      ),
      children: [
        for (var i = 0; i < data.projects.length; i++)
          _EntryFrame(
            index: i,
            count: data.projects.length,
            onMoveUp: () => edit(
              () => _ResumeEditorScreenState._reorder(data.projects, i, -1),
            ),
            onMoveDown: () => edit(
              () => _ResumeEditorScreenState._reorder(data.projects, i, 1),
            ),
            onDelete: () => edit(() => data.projects.removeAt(i)),
            child: Column(
              children: [
                EditorField(
                  label: 'Name',
                  value: data.projects[i].name,
                  onChanged: (v) => edit(() => data.projects[i].name = v),
                ),
                EditorField(
                  label: 'Tech / stack',
                  value: data.projects[i].tech,
                  onChanged: (v) => edit(() => data.projects[i].tech = v),
                ),
                EditorField(
                  label: 'Description',
                  value: data.projects[i].description,
                  maxLines: 5,
                  onChanged:
                      (v) => edit(() => data.projects[i].description = v),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReferencesSection extends StatelessWidget {
  const _ReferencesSection({required this.data, required this.edit});

  final ResumeData data;
  final void Function(VoidCallback) edit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'References',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Available on request'),
          value: data.referencesOnRequest,
          onChanged: (v) => edit(() => data.referencesOnRequest = v),
        ),
        if (data.referencesOnRequest)
          EditorField(
            label: 'On-request note',
            value: data.referencesNote,
            maxLines: 2,
            onChanged: (v) => edit(() => data.referencesNote = v),
          )
        else ...[
          for (var i = 0; i < data.references.length; i++)
            _EntryFrame(
              index: i,
              count: data.references.length,
              onMoveUp: () => edit(
                () => _ResumeEditorScreenState._reorder(data.references, i, -1),
              ),
              onMoveDown: () => edit(
                () => _ResumeEditorScreenState._reorder(data.references, i, 1),
              ),
              onDelete: () => edit(() => data.references.removeAt(i)),
              child: Column(
                children: [
                  EditorField(
                    label: 'Name',
                    value: data.references[i].name,
                    onChanged: (v) => edit(() => data.references[i].name = v),
                  ),
                  EditorField(
                    label: 'Organization',
                    value: data.references[i].organization,
                    onChanged:
                        (v) => edit(() => data.references[i].organization = v),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: EditorField(
                          label: 'Email',
                          value: data.references[i].email,
                          onChanged:
                              (v) => edit(() => data.references[i].email = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: EditorField(
                          label: 'Phone',
                          value: data.references[i].phone,
                          onChanged:
                              (v) => edit(() => data.references[i].phone = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => edit(() => data.references.add(ReferenceEntry())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add reference'),
            ),
          ),
        ],
      ],
    );
  }
}

class _EntryFrame extends StatelessWidget {
  const _EntryFrame({
    required this.index,
    required this.count,
    required this.child,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final int index;
  final int count;
  final Widget child;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          child,
          EntryControls(
            index: index,
            count: count,
            onMoveUp: onMoveUp,
            onMoveDown: onMoveDown,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

List<String> _splitCsv(String value) =>
    value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
