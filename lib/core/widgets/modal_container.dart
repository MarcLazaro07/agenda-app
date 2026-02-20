import 'dart:ui';
import 'package:flutter/material.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;

  const ModalContainer({
    super.key,
    required this.child,
    this.title,
    this.onClose,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ModalContainer(
          title: title,
          onClose: () => Navigator.of(context).pop(),
          child: child,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnimation = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: isWide ? 520 : size.width - 32,
          constraints: BoxConstraints(maxHeight: size.height * 0.88),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // ─── Header ───
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title!,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        if (onClose != null)
                          IconButton(
                            onPressed: onClose,
                            icon: Icon(
                              Icons.close_rounded,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                // ─── Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
