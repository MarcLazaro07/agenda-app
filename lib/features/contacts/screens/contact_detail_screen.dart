import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/providers.dart';
import '../../../models/contact_model.dart';
import '../../../models/category_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/contact_avatar.dart';
import '../../events/screens/event_detail_screen.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends ConsumerWidget {
  final ContactModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final currentContact = ref
        .watch(contactsProvider)
        .firstWhere((c) => c.id == contact.id, orElse: () => contact);

    final events = ref
        .watch(eventsProvider)
        .where((e) => e.personIds.contains(currentContact.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── Avatar ───
            ContactAvatar(
              name: currentContact.name,
              size: 90,
              isPlaceholder: currentContact.isMyProfile,
            ),
            const SizedBox(height: 16),
            Text(
              currentContact.isMyProfile ? 'Mi Perfil' : currentContact.name,
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ─── Info rows ───
            if (currentContact.phone != null &&
                currentContact.phone!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: LucideIcons.phone,
                label: 'Teléfono',
                value: currentContact.phone!,
              ),
            if (currentContact.email != null &&
                currentContact.email!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: LucideIcons.mail,
                label: 'Correo',
                value: currentContact.email!,
              ),
            if (currentContact.note != null && currentContact.note!.isNotEmpty)
              _buildInfoRow(
                context,
                icon: LucideIcons.stickyNote,
                label: 'Nota privada',
                value: currentContact.note!,
              ),

            // ─── Related events ───
            if (events.isNotEmpty) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Eventos relacionados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...events.map((event) {
                final categories = ref.watch(categoriesProvider);
                final category = categories.firstWhere(
                  (c) => c.id == event.categoryId,
                  orElse: () => const CategoryModel(
                    id: 'fallback',
                    name: 'General',
                    color: Colors.grey,
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (event.time != null)
                                  Text(
                                    event.time!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],

            // ─── Actions ───
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: LucideIcons.pencil,
                    isPrimary: true,
                    isExpanded: true,
                    onPressed: () {
                      ContactFormScreen.show(context, contact: currentContact);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Eliminar',
                    icon: LucideIcons.trash2,
                    isDestructive: true,
                    isExpanded: true,
                    onPressed: () async {
                      await ref
                          .read(contactsProvider.notifier)
                          .deleteContact(currentContact.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
