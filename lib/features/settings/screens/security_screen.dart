import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'La información en esta agenda está protegida mediante encriptación segura al momento de ser guardada en tu dispositivo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Desbloqueo Biométrico'),
            subtitle: const Text('Solicitar huella o rostro al abrir la app'),
            secondary: Icon(
              LucideIcons.fingerprint,
              color: theme.colorScheme.primary,
            ),
            value: _biometricsEnabled,
            onChanged: (val) => setState(() => _biometricsEnabled = val),
          ),
          ListTile(
            leading: Icon(
              LucideIcons.keyRound,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Cambiar código PIN'),
            subtitle: const Text('Configura un código de respaldo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo')),
              );
            },
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
          ),
        ],
      ),
    );
  }
}
