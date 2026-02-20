import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/providers.dart';
import '../../../models/event_model.dart';
import '../../../models/contact_model.dart';
import '../../../models/category_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends ConsumerWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // We watch the event from the provider in case it was edited
    final currentEvent = ref
        .watch(eventsProvider)
        .firstWhere((e) => e.id == event.id, orElse: () => event);

    final categories = ref.watch(categoriesProvider);
    final category = categories.firstWhere(
      (c) => c.id == currentEvent.categoryId,
      orElse: () => const CategoryModel(
        id: 'fallback',
        name: 'General',
        color: Colors.grey,
      ),
    );

    final allContacts = ref.watch(contactsProvider);
    final persons = currentEvent.personIds
        .map(
          (id) => allContacts.firstWhere(
            (c) => c.id == id,
            orElse: () => ContactModel(id: id, name: 'Unknown'),
          ),
        )
        .where((c) => c.name != 'Unknown')
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text('Detalle del Evento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Category & Priority row ───
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(context),
              ],
            ),
            const SizedBox(height: 20),

            Text(currentEvent.title, style: theme.textTheme.displaySmall),
            const SizedBox(height: 24),

            // ─── Date & Time ───
            _buildInfoRow(
              context,
              icon: LucideIcons.calendar,
              label: 'Fecha',
              value: DateFormat(
                'EEEE d \'de\' MMMM, yyyy',
                'es',
              ).format(currentEvent.date),
            ),
            if (currentEvent.time != null)
              _buildInfoRow(
                context,
                icon: LucideIcons.clock,
                label: 'Hora',
                value: currentEvent.endTime != null
                    ? '${currentEvent.time} — ${currentEvent.endTime}'
                    : currentEvent.time!,
              ),

            if (currentEvent.repetition != null)
              _buildInfoRow(
                context,
                icon: LucideIcons.repeat,
                label: 'Repetición',
                value: currentEvent.repetition!,
              ),

            if (currentEvent.place != null)
              _buildInfoRow(
                context,
                icon: LucideIcons.mapPin,
                label: 'Lugar',
                value: currentEvent.place!,
              ),

            if (currentEvent.reminder != null)
              _buildInfoRow(
                context,
                icon: LucideIcons.bell,
                label: 'Recordatorio',
                value: currentEvent.reminder!,
              ),

            if (currentEvent.description != null) ...[
              const SizedBox(height: 20),
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentEvent.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.6,
                ),
              ),
            ],

            // ─── Persons ───
            if (persons.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Personas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: persons.map((contact) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            contact!.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          contact.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            // ─── Actions ───
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Editar',
                    icon: LucideIcons.pencil,
                    isPrimary: true,
                    isExpanded: true,
                    onPressed: () {
                      EventFormScreen.show(context, event: currentEvent);
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
                          .read(eventsProvider.notifier)
                          .deleteEvent(currentEvent.id);
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
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildPriorityChip(BuildContext context) {
    final Color color;
    final String label;
    switch (event.priority) {
      case EventPriority.high:
        color = AppColors.priorityHigh;
        label = 'Alta';
        break;
      case EventPriority.medium:
        color = AppColors.priorityMedium;
        label = 'Media';
        break;
      case EventPriority.low:
        color = AppColors.priorityLow;
        label = 'Baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Prioridad $label',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
