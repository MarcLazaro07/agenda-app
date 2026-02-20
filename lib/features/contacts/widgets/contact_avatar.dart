import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool isPlaceholder;
  final Color? backgroundColor;

  const ContactAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.isPlaceholder = false,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getColorFromName(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;
    if (isPlaceholder) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15);
    }
    // Generate a consistent color from the name
    final hash = name.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.45, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getColorFromName(context);
    final textColor = isPlaceholder
        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
        : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
