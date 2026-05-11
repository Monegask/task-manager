import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Иконка приоритета задачи в стиле Linear — три вертикальных полосы
/// разной высоты, где заполненность показывает уровень важности.
enum TaskPriorityDisplay { high, normal, low, none }

class PriorityIcon extends StatelessWidget {
  const PriorityIcon({
    super.key,
    required this.priority,
    this.size = 14,
  });

  final TaskPriorityDisplay priority;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PriorityPainter(priority)),
    );
  }
}

class _PriorityPainter extends CustomPainter {
  const _PriorityPainter(this.priority);

  final TaskPriorityDisplay priority;

  static const _barCount = 3;

  Color get _color => switch (priority) {
        TaskPriorityDisplay.high => AppColors.priorityHigh,
        TaskPriorityDisplay.normal => AppColors.priorityMedium,
        TaskPriorityDisplay.low => AppColors.priorityLow,
        TaskPriorityDisplay.none => AppColors.priorityNone,
      };

  // Относительные высоты [0..1] для каждой из трёх полос
  List<double> get _heights => switch (priority) {
        TaskPriorityDisplay.high => [1.0, 1.0, 1.0],
        TaskPriorityDisplay.normal => [0.45, 0.75, 1.0],
        TaskPriorityDisplay.low => [0.45, 0.45, 0.45],
        TaskPriorityDisplay.none => [0.0, 0.0, 0.0],
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (priority == TaskPriorityDisplay.none) {
      // Пунктирный круг для «без приоритета»
      final paint = Paint()
        ..color = AppColors.priorityNone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2 - 1,
        paint,
      );
      return;
    }

    final barWidth = (size.width - (_barCount - 1) * 2) / _barCount;
    final heights = _heights;
    final filledPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;
    final emptyPaint = Paint()
      ..color = _color.withAlpha(40)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < _barCount; i++) {
      final x = i * (barWidth + 2);
      final fullH = size.height;
      final filledH = fullH * heights[i];

      const rr = Radius.circular(1);

      // Фоновая (пустая) часть полосы
      if (heights[i] < 1.0) {
        canvas.drawRRect(
          RRect.fromLTRBR(x, 0, x + barWidth, fullH, rr),
          emptyPaint,
        );
      }

      // Заполненная часть полосы (снизу)
      if (filledH > 0) {
        canvas.drawRRect(
          RRect.fromLTRBR(
            x,
            fullH - filledH,
            x + barWidth,
            fullH,
            rr,
          ),
          filledPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PriorityPainter old) => old.priority != priority;
}
