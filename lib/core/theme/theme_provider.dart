import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import '../../data/database_service.dart';

enum AppThemeMode { light, dark, amoled, system }

class ThemeState {
  final AppThemeMode mode;
  final Color accentColor;

  const ThemeState({required this.mode, required this.accentColor});

  ThemeState copyWith({AppThemeMode? mode, Color? accentColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final DatabaseService _dbService;

  ThemeNotifier(this._dbService)
    : super(
        ThemeState(
          mode: AppThemeMode.values.firstWhere(
            (e) =>
                e.name == (_dbService.settingsBox.get('themeMode') ?? 'system'),
            orElse: () => AppThemeMode.system,
          ),
          accentColor: Color(
            _dbService.settingsBox.get(
                  'accentColor',
                  defaultValue: AppColors.accent.value,
                )
                as int,
          ),
        ),
      );

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
    _dbService.settingsBox.put('themeMode', mode.name);
  }

  void setAccentColor(Color color) {
    state = state.copyWith(accentColor: color);
    _dbService.settingsBox.put('accentColor', color.value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(DatabaseService());
});
