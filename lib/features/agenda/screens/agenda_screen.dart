import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/providers.dart';
import '../../../models/event_model.dart';
import '../../../models/category_model.dart';
import '../widgets/agenda_header.dart';
import '../widgets/calendar_controller.dart';
import '../widgets/event_list_tile.dart';
import '../../events/screens/event_detail_screen.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  List<EventModel> _getEventsForSelectedDay(List<EventModel> events) {
    return events.where((e) {
      return e.date.year == _selectedDate.year &&
          e.date.month == _selectedDate.month &&
          e.date.day == _selectedDate.day;
    }).toList()..sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
  }

  Map<DateTime, List<EventModel>> _getEventsByDay(List<EventModel> events) {
    final map = <DateTime, List<EventModel>>{};
    for (final event in events) {
      final key = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(key, () => []).add(event);
    }
    return map;
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _goToToday() {
    setState(() => _selectedDate = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Builder(
        builder: (context) {
          final eventsList = ref.watch(eventsProvider);
          return Column(
            children: [
              AgendaHeader(
                selectedDate: _selectedDate,
                onTodayPressed: _goToToday,
              ),
              Expanded(
                child: CalendarController(
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateSelected,
                  eventsByDay: _getEventsByDay(eventsList),
                  eventListBuilder: (showList) {
                    if (!showList) return const SizedBox.shrink();
                    return _buildEventList(eventsList);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<EventModel> allEvents) {
    final events = _getEventsForSelectedDay(allEvents);

    if (events.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.calendarOff,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Text(
                'Sin eventos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE d', 'es').format(_selectedDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: events.length,
        separatorBuilder: (_, _2) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final event = events[index];
          final categories = ref.watch(categoriesProvider);
          final category = categories.firstWhere(
            (c) => c.id == event.categoryId,
            orElse: () => const CategoryModel(
              id: 'fallback',
              name: 'General',
              color: Colors.grey,
            ),
          );
          return EventListTile(
            event: event,
            categoryColor: category.color,
            categoryName: category.name,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
