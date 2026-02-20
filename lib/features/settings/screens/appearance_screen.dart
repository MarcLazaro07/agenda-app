import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);

    // Provide 4 distinct accent colors to choose from
    const accentColorOptions = [
      {'color': AppColors.accent, 'name': 'Índigo'},
      {'color': AppColors.coral, 'name': 'Coral'},
      {'color': AppColors.amber, 'name': 'Ámbar'},
      {'color': AppColors.success, 'name': 'Menta'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apariencia'),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Tema visual',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeCard(
            context: context,
            title: 'Automático (Sistema)',
            subtitle: 'Sigue la configuración de tu dispositivo',
            value: AppThemeMode.system,
            groupValue: themeState.mode,
            onChanged: (val) =>
                ref.read(themeProvider.notifier).setThemeMode(val),
          ),
          const SizedBox(height: 12),
          _buildThemeCard(
            context: context,
            title: 'Claro',
            subtitle: 'Fondo blanco, ideal para ambientes iluminados',
            value: AppThemeMode.light,
            groupValue: themeState.mode,
            onChanged: (val) =>
                ref.read(themeProvider.notifier).setThemeMode(val),
          ),
          const SizedBox(height: 12),
          _buildThemeCard(
            context: context,
            title: 'Oscuro',
            subtitle: 'Fondo gris oscuro, cómodo para la vista',
            value: AppThemeMode.dark,
            groupValue: themeState.mode,
            onChanged: (val) =>
                ref.read(themeProvider.notifier).setThemeMode(val),
          ),
          const SizedBox(height: 12),
          _buildThemeCard(
            context: context,
            title: 'Oscuro (AMOLED)',
            subtitle: 'Fondo negro profundo, ahorra batería en pantallas OLED',
            value: AppThemeMode.amoled,
            groupValue: themeState.mode,
            onChanged: (val) =>
                ref.read(themeProvider.notifier).setThemeMode(val),
          ),

          const SizedBox(height: 48),

          Text(
            'Color principal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: accentColorOptions.map((option) {
              final color = option['color'] as Color;
              final name = option['name'] as String;
              final isSelected = themeState.accentColor.value == color.value;

              return GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).setAccentColor(color);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              LucideIcons.check,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required AppThemeMode value,
    required AppThemeMode groupValue,
    required ValueChanged<AppThemeMode> onChanged,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.05)
          : theme.cardColor,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
