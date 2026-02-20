import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/modal_container.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../models/event_model.dart';
import '../../../models/contact_model.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  final EventModel? existingEvent;

  const EventFormScreen({super.key, this.existingEvent});

  static Future<void> show(BuildContext context, {EventModel? event}) {
    return ModalContainer.show(
      context,
      title: event != null ? 'Editar Evento' : 'Nuevo Evento',
      child: EventFormScreen(existingEvent: event),
    );
  }

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  EventPriority? _selectedPriority;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime = '09:00';
  List<String> _selectedPersonIds = [];
  String? _selectedReminder;
  String? _selectedRepetition;

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      final e = widget.existingEvent!;
      _titleController.text = e.title;
      _placeController.text = e.place ?? '';
      _descriptionController.text = e.description ?? '';
      _selectedCategoryId = e.categoryId;
      _selectedPriority = e.priority;
      _selectedDate = e.date;
      _selectedTime = e.time;
      _selectedPersonIds = List.from(e.personIds);
      _selectedReminder = e.reminder;
      _selectedRepetition = e.repetition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Title ───
        CustomTextField(
          label: 'Título',
          hint: 'Nombre del evento',
          controller: _titleController,
          prefixIcon: LucideIcons.type,
        ),
        const SizedBox(height: 20),

        // ─── Date ───
        CustomTextField(
          label: 'Fecha',
          hint:
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          prefixIcon: LucideIcons.calendar,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
        ),
        const SizedBox(height: 20),

        // ─── Time ───
        CustomTextField(
          label: 'Hora',
          hint: _selectedTime ?? 'Seleccionar hora',
          prefixIcon: LucideIcons.clock,
          readOnly: true,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              setState(
                () => _selectedTime =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              );
            }
          },
        ),
        const SizedBox(height: 20),

        // ─── Repetition ───
        _buildDropdownField(
          label: 'Repetición',
          icon: LucideIcons.repeat,
          value: _selectedRepetition,
          items: const ['Diario', 'Semanal', 'Mensual', 'Anual'],
          onChanged: (v) => setState(() => _selectedRepetition = v),
        ),
        const SizedBox(height: 20),

        // ─── Category ───
        Text(
          'Categoría',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value:
              (ref
                  .watch(categoriesProvider)
                  .any((c) => c.id == _selectedCategoryId))
              ? _selectedCategoryId
              : (ref.watch(categoriesProvider).isNotEmpty
                    ? ref.watch(categoriesProvider).first.id
                    : null),
          decoration: InputDecoration(
            prefixIcon: Icon(
              LucideIcons.tag,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          items: ref.watch(categoriesProvider).map((cat) {
            return DropdownMenuItem(
              value: cat.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(cat.name, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategoryId = val);
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              // TODO: Navigate to categories admin
            },
            icon: const Icon(LucideIcons.settings2, size: 14),
            label: const Text('Administrar categorías'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.bodySmall,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ─── Priority ───
        Text(
          'Prioridad',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: EventPriority.values.map((p) {
            final isSelected = p == _selectedPriority;
            final Color color;
            final String label;
            switch (p) {
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
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? color : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // ─── Persons ───
        Text(
          'Personas',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ..._selectedPersonIds.map((id) {
              final allContacts = ref.watch(contactsProvider);
              final contact = allContacts.firstWhere(
                (c) => c.id == id,
                orElse: () => ContactModel(id: id, name: 'Unknown'),
              );
              if (contact.name == 'Unknown') return const SizedBox.shrink();
              return Chip(
                label: Text(contact.name),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _selectedPersonIds.remove(id));
                },
              );
            }),
            InkWell(
              onTap: () => _showPersonPicker(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(LucideIcons.plus, color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ─── Place ───
        CustomTextField(
          label: 'Lugar',
          hint: 'Ubicación del evento',
          controller: _placeController,
          prefixIcon: LucideIcons.mapPin,
        ),
        const SizedBox(height: 20),

        // ─── Reminder ───
        _buildDropdownField(
          label: 'Recordatorio',
          icon: LucideIcons.bell,
          value: _selectedReminder,
          items: const [
            '5 minutos antes',
            '15 minutos antes',
            '30 minutos antes',
            '1 hora antes',
            '3 horas antes',
            '1 día antes',
          ],
          onChanged: (v) => setState(() => _selectedReminder = v),
        ),
        const SizedBox(height: 20),

        // ─── Description ───
        CustomTextField(
          label: 'Descripción',
          hint: 'Notas sobre el evento...',
          controller: _descriptionController,
          maxLines: 3,
          prefixIcon: LucideIcons.alignLeft,
        ),
        const SizedBox(height: 20),

        // ─── Attachments placeholder ───
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.paperclip,
                size: 24,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Adjuntar archivos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
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
                  final newEvent = EventModel(
                    id: widget.existingEvent?.id ?? const Uuid().v4(),
                    title: _titleController.text.trim().isEmpty
                        ? 'Nuevo Evento'
                        : _titleController.text.trim(),
                    date: _selectedDate,
                    time: _selectedTime,
                    categoryId:
                        _selectedCategoryId ??
                        (ref.read(categoriesProvider).isNotEmpty
                            ? ref.read(categoriesProvider).first.id
                            : 'cat_personal'),
                    priority: _selectedPriority ?? EventPriority.medium,
                    personIds: _selectedPersonIds,
                    place: _placeController.text.trim().isEmpty
                        ? null
                        : _placeController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    reminder: _selectedReminder,
                    repetition: _selectedRepetition,
                  );

                  if (widget.existingEvent != null) {
                    await ref
                        .read(eventsProvider.notifier)
                        .updateEvent(newEvent);
                  } else {
                    await ref.read(eventsProvider.notifier).addEvent(newEvent);
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          hint: Text(
            'Seleccionar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: theme.textTheme.bodyMedium),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showPersonPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seleccionar Personas',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ref.watch(contactsProvider).length,
                      itemBuilder: (context, index) {
                        final contact = ref.watch(contactsProvider)[index];
                        if (contact.isMyProfile) return const SizedBox.shrink();
                        final isSelected = _selectedPersonIds.contains(
                          contact.id,
                        );
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Text(
                              contact.name.isNotEmpty ? contact.name[0] : '?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Text(contact.name),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPersonIds.remove(contact.id);
                              } else {
                                _selectedPersonIds.add(contact.id);
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
