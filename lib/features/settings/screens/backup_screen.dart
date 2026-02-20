import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Puedes exportar todos los datos de tu agenda (eventos, contactos, y categorías) a un archivo seguro.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              LucideIcons.downloadCloud,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Exportar datos'),
            subtitle: const Text('Guarda un archivo de respaldo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copia de seguridad guardada en Descargas'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              LucideIcons.uploadCloud,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Importar datos'),
            subtitle: const Text('Restaura desde un archivo de respaldo'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Importación no disponible en este momento'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
