import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Заглушка — Настройки. Будет реализован в Stage 6.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Настройки')),
      body: Center(
        child: Text('Будет реализовано в Stage 6', style: AppTextStyles.emptyState),
      ),
    );
  }
}
