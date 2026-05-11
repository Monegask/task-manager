import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'priority_icon.dart';
import 'status_icon.dart';

/// Строка задачи в стиле Linear.
///
/// Принимает примитивные значения, чтобы не зависеть от доменных моделей
/// до Stage 1. После Stage 1 будет обёрнут в Task → TaskTile mapper.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    this.scheduledLabel,
    this.tags = const [],
    this.onTap,
    this.onStatusTap,
  });

  final String id;
  final String title;
  final TaskStatusDisplay status;
  final TaskPriorityDisplay priority;
  final String? scheduledLabel;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.bgHover,
      splashColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority icon
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 8),
              child: PriorityIcon(priority: priority, size: 13),
            ),

            // Status icon — tappable
            GestureDetector(
              onTap: onStatusTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 1, right: 10),
                child: StatusIcon(status: status, size: 16),
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: status == TaskStatusDisplay.completed
                        ? AppTextStyles.taskTitleCompleted
                        : AppTextStyles.taskTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (scheduledLabel != null || tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(id, style: AppTextStyles.taskId),
                        if (scheduledLabel != null) ...[
                          Text(' · ', style: AppTextStyles.taskId),
                          Text(scheduledLabel!, style: AppTextStyles.taskMeta),
                        ],
                        const SizedBox(width: 6),
                        ...tags.map(
                          (tag) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _TagChip(label: tag),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTextStyles.chip),
    );
  }
}
