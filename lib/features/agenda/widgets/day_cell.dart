import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/event_model.dart';
import '../../../models/category_model.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/app_constants.dart';
import 'calendar_controller.dart';

class DayCell extends ConsumerWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final List<EventModel> events;
  final CalendarState viewState;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isCurrentMonth,
    required this.events,
    required this.viewState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final textColor = isSelected
        ? Colors.white
        : isToday
        ? theme.colorScheme.primary
        : isCurrentMonth
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.3);

    final bgColor = isSelected
        ? theme.colorScheme.primary
        : isToday
        ? theme.colorScheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    final isCompact = viewState == CalendarState.monthlyCompact;
    final isFull = viewState == CalendarState.monthlyFull;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(isFull ? 6 : 2),
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 4 : (isFull ? 12 : 6),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(isFull ? 16 : 10),
        ),
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Day number ───
              Text(
                '$day',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: isFull ? 18 : (isCompact ? 11 : 13),
                ),
              ),
              if (events.isNotEmpty) ...[
                SizedBox(height: isCompact ? 2 : (isFull ? 8 : 4)),
                _buildEventBars(context, ref),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventBars(BuildContext context, WidgetRef ref) {
    final isCompact = viewState == CalendarState.monthlyCompact;
    final isFull = viewState == CalendarState.monthlyFull;

    final maxBars = isFull
        ? 4
        : (isCompact ? 2 : AppConstants.maxVisibleEventBars);
    final visibleEvents = events.take(maxBars).toList();
    final overflow = events.length - maxBars;

    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        ...visibleEvents.map((event) {
          final category = categories.firstWhere(
            (c) => c.id == event.categoryId,
            orElse: () => const CategoryModel(
              id: 'fallback',
              name: 'General',
              color: Colors.grey,
            ),
          );
          return Container(
            height: isFull ? 4.0 : (isCompact ? 2.0 : 3.0),
            width: isFull ? 36.0 : (isCompact ? 14.0 : 20.0),
            margin: EdgeInsets.symmetric(vertical: isFull ? 1.5 : 0.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.7)
                  : category.color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        }),
        if (overflow > 0)
          Padding(
            padding: EdgeInsets.only(top: isFull ? 2 : 1),
            child: Text(
              '+$overflow',
              style: TextStyle(
                fontSize: isFull ? 10 : 8,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}
