import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Типографика на базе Inter — основного шрифта Linear.
abstract final class AppTextStyles {
  // ── Заголовки ──────────────────────────────────────────────────────────────
  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.6,
      );

  // ── Задача ─────────────────────────────────────────────────────────────────
  static TextStyle get taskTitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
      );

  static TextStyle get taskTitleCompleted => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        letterSpacing: -0.1,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.textTertiary,
      );

  static TextStyle get taskMeta => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  static TextStyle get taskId => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textDisabled,
      );

  // ── Теги / чипы ───────────────────────────────────────────────────────────
  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.tagText,
      );

  // ── Bottom nav ────────────────────────────────────────────────────────────
  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  // ── Общий body ────────────────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondary,
      );

  static TextStyle get emptyState => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );
}
