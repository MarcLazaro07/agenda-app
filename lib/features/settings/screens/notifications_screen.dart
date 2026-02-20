import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enableNotifications = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SwitchListTile(
            title: const Text('Activar notificaciones'),
            subtitle: const Text('Recibe recordatorios de tus eventos'),
            secondary: Icon(
              LucideIcons.bellRing,
              color: theme.colorScheme.primary,
            ),
            value: _enableNotifications,
            onChanged: (val) => setState(() => _enableNotifications = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Sonido de notificación'),
            subtitle: const Text(
              'Reproducir un sonido cuando llega una alerta',
            ),
            secondary: Icon(
              LucideIcons.volume2,
              color: theme.colorScheme.primary,
            ),
            value: _soundEnabled,
            onChanged: _enableNotifications
                ? (val) => setState(() => _soundEnabled = val)
                : null,
          ),
        ],
      ),
    );
  }
}
