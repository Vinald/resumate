import 'package:flutter/material.dart';

import '../../models/contact_info.dart';
import '../widgets/editor_widgets.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.contact,
    required this.onChanged,
  });

  final ContactInfo contact;
  final ValueChanged<ContactInfo> onChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Contact',
      children: [
        EditorField(
          label: 'Full name',
          value: contact.name,
          onChanged: (v) => onChanged(contact.copyWith(name: v)),
        ),
        EditorField(
          label: 'Title / headline',
          value: contact.title,
          onChanged: (v) => onChanged(contact.copyWith(title: v)),
        ),
        EditorField(
          label: 'Phone',
          value: contact.phone,
          onChanged: (v) => onChanged(contact.copyWith(phone: v)),
        ),
        EditorField(
          label: 'Email',
          value: contact.email,
          onChanged: (v) => onChanged(contact.copyWith(email: v)),
        ),
        EditorField(
          label: 'Portfolio URL',
          value: contact.portfolioUrl,
          onChanged: (v) => onChanged(contact.copyWith(portfolioUrl: v)),
        ),
        Row(
          children: [
            Expanded(
              child: EditorField(
                label: 'GitHub URL',
                value: contact.githubUrl,
                onChanged: (v) => onChanged(contact.copyWith(githubUrl: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditorField(
                label: 'GitHub label',
                value: contact.githubLabel,
                onChanged: (v) => onChanged(contact.copyWith(githubLabel: v)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: EditorField(
                label: 'LinkedIn URL',
                value: contact.linkedinUrl,
                onChanged: (v) => onChanged(contact.copyWith(linkedinUrl: v)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditorField(
                label: 'LinkedIn label',
                value: contact.linkedinLabel,
                onChanged:
                    (v) => onChanged(contact.copyWith(linkedinLabel: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
