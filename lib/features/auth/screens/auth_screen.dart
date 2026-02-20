import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AuthScreen extends StatefulWidget {
  final Widget child;

  const AuthScreen({super.key, required this.child});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _checkSupportAndAuthenticate();
  }

  Future<void> _checkSupportAndAuthenticate() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
      return;
    }

    bool isSupported = false;
    try {
      isSupported = await auth.isDeviceSupported();
    } catch (_) {
      isSupported = false;
    }

    if (!isSupported) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isAuthenticating = false;
        });
      }
      return;
    }
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _errorMsg = '';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Desbloquea Agenda para acceder a tus datos privados',
      );
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error al autenticar: ${e.message}';
          _isAuthenticating = false;
        });
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticated = authenticated;
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) return widget.child;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shieldAlert,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Agenda Bloqueada',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tus datos están encriptados y protegidos.\nVerifica tu identidad para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            if (_errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
                child: Text(
                  _errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!_isAuthenticating)
              FilledButton.icon(
                icon: const Icon(LucideIcons.fingerprint),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _authenticate,
              ),
            if (_isAuthenticating) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
