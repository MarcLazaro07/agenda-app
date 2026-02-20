import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AgendaHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTodayPressed;

  const AgendaHeader({
    super.key,
    required this.selectedDate,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ─── Date display ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedDate.day}',
                  style: theme.textTheme.displayLarge?.copyWith(height: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM yyyy', 'es').format(selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // ─── Actions ───
          if (!isToday)
            TextButton.icon(
              onPressed: onTodayPressed,
              icon: const Icon(LucideIcons.calendarCheck, size: 16),
              label: const Text('Hoy'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
