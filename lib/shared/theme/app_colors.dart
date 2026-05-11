import 'package:flutter/material.dart';

/// Цветовая система, вдохновлённая Linear.
/// Все значения — константы, не требуют контекста.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bg = Color(0xFF11111B);
  static const bgSurface = Color(0xFF161623);
  static const bgElevated = Color(0xFF1E1E2E);
  static const bgHover = Color(0xFF252535);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border = Color(0x12FFFFFF); // white 7%
  static const borderStrong = Color(0x1FFFFFFF); // white 12%

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFE2E2E9);
  static const textSecondary = Color(0xFF9293A4);
  static const textTertiary = Color(0xFF5B5C6E);
  static const textDisabled = Color(0xFF3D3D52);

  // ── Brand accent ───────────────────────────────────────────────────────────
  static const accent = Color(0xFF5E6AD2);
  static const accentSoft = Color(0x1A5E6AD2); // accent 10%

  // ── Status ─────────────────────────────────────────────────────────────────
  static const statusTodo = Color(0xFF9293A4);
  static const statusInProgress = Color(0xFF5E6AD2);
  static const statusDone = Color(0xFF30A46C);
  static const statusCanceled = Color(0xFF5B5C6E);

  // ── Priority ───────────────────────────────────────────────────────────────
  static const priorityUrgent = Color(0xFFE5484D);
  static const priorityHigh = Color(0xFFF76B15);
  static const priorityMedium = Color(0xFFF5A623);
  static const priorityLow = Color(0xFF9293A4);
  static const priorityNone = Color(0xFF3D3D52);

  // ── Tag chips ──────────────────────────────────────────────────────────────
  static const tagBg = Color(0x14FFFFFF);
  static const tagText = Color(0xFF9293A4);
}
