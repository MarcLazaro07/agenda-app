import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Light Theme ───
  static const Color lightBackground = Color(0xFFFCFCFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F8);
  static const Color lightTextPrimary = Color(0xFF1E1E24);
  static const Color lightTextSecondary = Color(0xFF6E6E7A);
  static const Color lightTextTertiary = Color(0xFF9E9EA8);
  static const Color lightBorder = Color(0xFFEAEAEE);
  static const Color lightDivider = Color(0xFFF0F0F4);

  // ─── Dark Theme (Standard) ───
  static const Color darkBackground = Color(0xFF13131A);
  static const Color darkSurface = Color(0xFF1E1E28);
  static const Color darkSurfaceVariant = Color(0xFF262635);
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFA0A0AB);
  static const Color darkTextTertiary = Color(0xFF70707D);
  static const Color darkBorder = Color(0xFF323246);
  static const Color darkDivider = Color(0xFF242436);

  // ─── Dark Theme (AMOLED) ───
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF09090C);
  static const Color amoledSurfaceVariant = Color(0xFF121218);
  static const Color amoledBorder = Color(0xFF1F1F27);
  static const Color amoledDivider = Color(0xFF17171C);

  // ─── Accent Colors ───
  static const Color accent = Color(0xFF635BFF); // Electric Indigo
  static const Color accentLight = Color(0xFF837DFF);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color amber = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00D194);

  // ─── Category Default Colors ───
  static const List<Color> categoryColors = [
    Color(0xFF635BFF), // Indigo
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFB347), // Amber
    Color(0xFF00D194), // Mint
    Color(0xFFB57EDC), // Lavender
    Color(0xFFFF66A3), // Pink
    Color(0xFF4DB8FF), // Azure
    Color(0xFFE6D72A), // Lemon
  ];

  static const List<String> categoryColorNames = [
    'Indigo',
    'Coral',
    'Amber',
    'Mint',
    'Lavender',
    'Pink',
    'Azure',
    'Lemon',
  ];

  // ─── Priority Colors ───
  static const Color priorityHigh = Color(0xFFFF4D4D);
  static const Color priorityMedium = Color(0xFFFFB347);
  static const Color priorityLow = Color(0xFF00D194);
}
