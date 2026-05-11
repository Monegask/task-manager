import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Заглушка — «Все задачи». Будет реализован в Stage 3.
class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Все задачи')),
      body: Center(
        child: Text('Будет реализовано в Stage 3', style: AppTextStyles.emptyState),
      ),
    );
  }
}
