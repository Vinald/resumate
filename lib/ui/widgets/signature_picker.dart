import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/settings_store.dart';

/// Pick / preview / remove the signature image. The image is stored once in
/// [SettingsStore] and reused by every letter (PDF and `.tex` output).
class SignaturePicker extends StatelessWidget {
  const SignaturePicker({super.key, this.dense = false});

  final bool dense;

  Future<void> _pick(BuildContext context) async {
    final store = context.read<SettingsStore>();
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(file.path).copy('${dir.path}/signature.png');
    await store.update(
      store.settings.copyWith(signatureImagePath: saved.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SettingsStore>();
    final path = store.settings.signatureImagePath;
    final hasImage = path != null && File(path).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!dense)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Signature',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        if (hasImage)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.file(
              File(path),
              height: 56,
              alignment: Alignment.centerLeft,
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'No signature added yet.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.draw, size: 18),
              label: Text(hasImage ? 'Replace' : 'Add signature'),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    () => store.update(
                      store.settings.copyWith(clearSignature: true),
                    ),
                child: const Text('Remove'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Appears above your name on letter PDFs. For .tex export, the image '
          'is shared alongside the file as signature.png.',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
