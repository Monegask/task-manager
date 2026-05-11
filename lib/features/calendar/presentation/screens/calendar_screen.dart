import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Заглушка — Календарь. Будет реализован в Stage 4.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Календарь')),
      body: Center(
        child: Text('Будет реализовано в Stage 4', style: AppTextStyles.emptyState),
      ),
    );
  }
}
