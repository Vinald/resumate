import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/settings_store.dart';
import '../../models/app_settings.dart';
import '../widgets/editor_widgets.dart';
import '../resume_editor/contact_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SettingsStore>();
    final s = store.settings;

    void update(AppSettings next) => store.update(next);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ContactSection(
            contact: s.defaultContact,
            onChanged: (c) => update(s.copyWith(defaultContact: c)),
          ),
          SectionCard(
            title: 'Style',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Accent colour'),
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Color(s.accentColor),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                onTap: () async {
                  var picked = Color(s.accentColor);
                  final ok = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Accent colour'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: picked,
                              onColorChanged: (c) => picked = c,
                              enableAlpha: false,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Use'),
                            ),
                          ],
                        ),
                  );
                  if (ok == true) {
                    // ignore: use_build_context_synchronously
                    update(s.copyWith(accentColor: picked.toARGB32()));
                  }
                },
              ),
              DropdownButtonFormField<BodyFont>(
                initialValue: s.bodyFont,
                decoration: const InputDecoration(labelText: 'Body font'),
                items: [
                  for (final f in BodyFont.values)
                    DropdownMenuItem(value: f, child: Text(f.label)),
                ],
                onChanged: (f) => f == null ? null : update(s.copyWith(bodyFont: f)),
              ),
              const SizedBox(height: 12),
              _slider(
                'Page margin',
                '${s.marginInches.toStringAsFixed(2)} in',
                s.marginInches,
                0.3,
                1.0,
                (v) => update(s.copyWith(marginInches: v)),
              ),
              _slider(
                'Line spacing',
                s.lineSpacing.toStringAsFixed(2),
                s.lineSpacing,
                1.0,
                1.6,
                (v) => update(s.copyWith(lineSpacing: v)),
              ),
            ],
          ),
          SectionCard(
            title: 'Signature',
            children: [
              if (s.signatureImagePath != null &&
                  File(s.signatureImagePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.file(
                    File(s.signatureImagePath!),
                    height: 60,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file == null) return;
                      final dir = await getApplicationDocumentsDirectory();
                      final saved = await File(
                        file.path,
                      ).copy('${dir.path}/signature.png');
                      update(s.copyWith(signatureImagePath: saved.path));
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Choose image'),
                  ),
                  const SizedBox(width: 8),
                  if (s.signatureImagePath != null)
                    TextButton(
                      onPressed: () => update(s.copyWith(clearSignature: true)),
                      child: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label — $value'),
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 20).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

