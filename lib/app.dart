import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/responsive_scaffold.dart';
import 'features/agenda/screens/agenda_screen.dart';
import 'features/contacts/screens/contacts_screen.dart';
import 'features/contacts/screens/contact_form_screen.dart';
import 'features/events/screens/event_form_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/auth/screens/auth_screen.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class AgendaApp extends ConsumerWidget {
  const AgendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    ThemeData? darkThemeToUse;
    ThemeMode flutterThemeMode;

    switch (themeState.mode) {
      case AppThemeMode.light:
        flutterThemeMode = ThemeMode.light;
        darkThemeToUse = AppTheme.dark(themeState.accentColor); // fallback
        break;
      case AppThemeMode.dark:
        flutterThemeMode = ThemeMode.dark;
        darkThemeToUse = AppTheme.dark(themeState.accentColor);
        break;
      case AppThemeMode.amoled:
        flutterThemeMode = ThemeMode.dark;
        darkThemeToUse = AppTheme.amoled(themeState.accentColor);
        break;
      case AppThemeMode.system:
        flutterThemeMode = ThemeMode.system;
        darkThemeToUse = AppTheme.dark(themeState.accentColor);
        break;
    }

    return MaterialApp(
      title: 'Agenda',
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      theme: AppTheme.light(themeState.accentColor),
      darkTheme: darkThemeToUse,
      themeMode: flutterThemeMode,
      home: const AuthScreen(child: _AppShell()),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    AgendaScreen(),
    ContactsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  void _onFabPressed() {
    if (_currentIndex == 0) {
      EventFormScreen.show(context);
    } else if (_currentIndex == 1) {
      ContactFormScreen.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      screens: _screens,
      onFabPressed: _onFabPressed,
    );
  }
}
