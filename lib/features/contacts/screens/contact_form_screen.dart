import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/modal_container.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/providers.dart';
import '../../../models/contact_model.dart';
import '../widgets/contact_avatar.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  final ContactModel? existingContact;

  const ContactFormScreen({super.key, this.existingContact});

  static Future<void> show(BuildContext context, {ContactModel? contact}) {
    return ModalContainer.show(
      context,
      title: contact != null ? 'Editar Contacto' : 'Nuevo Contacto',
      child: ContactFormScreen(existingContact: contact),
    );
  }

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingContact != null) {
      final c = widget.existingContact!;
      _nameController.text = c.name;
      _phoneController.text = c.phone ?? '';
      _emailController.text = c.email ?? '';
      _noteController.text = c.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Avatar preview ───
        Center(
          child: GestureDetector(
            onTap: () {
              // TODO: photo picker
            },
            child: Stack(
              children: [
                ContactAvatar(
                  name: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : '?',
                  size: 80,
                  isPlaceholder: _nameController.text.isEmpty,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ─── Name ───
        CustomTextField(
          label: 'Nombre completo',
          hint: 'Nombre y apellido',
          controller: _nameController,
          prefixIcon: LucideIcons.user,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),

        // ─── Phone ───
        CustomTextField(
          label: 'Teléfono',
          hint: '+52 555 123 4567',
          controller: _phoneController,
          prefixIcon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        // ─── Email ───
        CustomTextField(
          label: 'Correo electrónico',
          hint: 'correo@ejemplo.com',
          controller: _emailController,
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // ─── Note ───
        CustomTextField(
          label: 'Nota privada',
          hint: 'Notas sobre este contacto...',
          controller: _noteController,
          prefixIcon: LucideIcons.stickyNote,
          maxLines: 3,
        ),
        const SizedBox(height: 28),

        // ─── Actions ───
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Cancelar',
                isPrimary: false,
                isExpanded: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Guardar',
                icon: LucideIcons.check,
                isExpanded: true,
                onPressed: () async {
                  final newContact = ContactModel(
                    id: widget.existingContact?.id ?? const Uuid().v4(),
                    name: _nameController.text.trim().isEmpty
                        ? 'Nuevo Contacto'
                        : _nameController.text.trim(),
                    phone: _phoneController.text.trim().isEmpty
                        ? null
                        : _phoneController.text.trim(),
                    email: _emailController.text.trim().isEmpty
                        ? null
                        : _emailController.text.trim(),
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                    avatarUrl: widget.existingContact?.avatarUrl,
                    isMyProfile: widget.existingContact?.isMyProfile ?? false,
                  );

                  if (widget.existingContact != null) {
                    await ref
                        .read(contactsProvider.notifier)
                        .updateContact(newContact);
                  } else {
                    await ref
                        .read(contactsProvider.notifier)
                        .addContact(newContact);
                  }

                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
