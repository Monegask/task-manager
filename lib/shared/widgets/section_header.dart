import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Шапка группы задач (TODO / IN PROGRESS / DONE).
/// Стиль: маленький uppercase текст с количеством задач.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.sectionHeader),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.tagBg,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.sectionHeader.copyWith(
                letterSpacing: 0,
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
