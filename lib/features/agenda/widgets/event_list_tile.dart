import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../models/event_model.dart';
import '../../../core/theme/app_colors.dart';

class EventListTile extends StatelessWidget {
  final EventModel event;
  final Color categoryColor;
  final String categoryName;
  final VoidCallback? onTap;

  const EventListTile({
    super.key,
    required this.event,
    required this.categoryColor,
    required this.categoryName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ─── Category color bar ───
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              // ─── Content ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // ─── Time ───
                      if (event.time != null)
                        SizedBox(
                          width: 50,
                          child: Text(
                            event.time!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      // ─── Title + category ───
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              categoryName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ─── Priority + persons ───
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (event.personIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                LucideIcons.users,
                                size: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          _buildPriorityBadge(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
