import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<Widget> screens;
  final VoidCallback? onFabPressed;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.screens,
    this.onFabPressed,
  });

  bool get _showFab => currentIndex == 0 || currentIndex == 1;

  IconData get _fabIcon =>
      currentIndex == 0 ? LucideIcons.calendarPlus : LucideIcons.userPlus;

  String get _fabTooltip =>
      currentIndex == 0 ? 'Nuevo Evento' : 'Nuevo Contacto';

  static const _navItems = [
    _NavItem(icon: LucideIcons.calendar, label: 'Agenda'),
    _NavItem(icon: LucideIcons.users, label: 'Contactos'),
    _NavItem(icon: LucideIcons.search, label: 'Buscar'),
    _NavItem(icon: LucideIcons.settings, label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > AppConstants.tabletBreakpoint;

    if (isWide) {
      return _buildSidebarLayout(context);
    }
    return _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: screens[currentIndex],
        ),
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
                  onPressed: onFabPressed,
                  tooltip: _fabTooltip,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(_fabIcon, key: ValueKey(_fabIcon)),
                  ),
                )
                .animate(key: const ValueKey('fab'))
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppConstants.bottomNavHeight,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = i == currentIndex;
                return Expanded(
                  child: _NavBarButton(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => onTabChanged(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // ─── Sidebar ───
          Container(
            width: AppConstants.sidebarWidth,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── App Title ───
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.calendarDays,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Agenda',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ─── Nav items ───
                  ...List.generate(_navItems.length, (i) {
                    final item = _navItems[i];
                    final isSelected = i == currentIndex;
                    return _SidebarButton(
                      icon: item.icon,
                      label: item.label,
                      isSelected: isSelected,
                      onTap: () => onTabChanged(i),
                    );
                  }),
                  const Spacer(),
                  // ─── FAB in sidebar ───
                  if (_showFab)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: onFabPressed,
                          icon: Icon(_fabIcon, size: 18),
                          label: Text(
                            currentIndex == 0
                                ? 'Nuevo Evento'
                                : 'Nuevo Contacto',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // ─── Content ───
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(currentIndex),
                child: screens[currentIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ───

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: widget.isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : _hovering
                ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 20, color: color),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
