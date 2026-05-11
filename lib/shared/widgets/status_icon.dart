import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Иконка статуса задачи в стиле Linear.
///
/// active  → пустой кружок с цветной рамкой
/// completed → залитый кружок с галочкой
enum TaskStatusDisplay { active, completed }

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    super.key,
    required this.status,
    this.size = 16,
  });

  final TaskStatusDisplay status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StatusPainter(status),
      ),
    );
  }
}

class _StatusPainter extends CustomPainter {
  const _StatusPainter(this.status);

  final TaskStatusDisplay status;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1;

    switch (status) {
      case TaskStatusDisplay.active:
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = AppColors.statusTodo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      case TaskStatusDisplay.completed:
        // Залитый круг
        canvas.drawCircle(
          center,
          r + 1,
          Paint()
            ..color = AppColors.statusDone
            ..style = PaintingStyle.fill,
        );
        // Галочка
        final s = size.width;
        final path = Path()
          ..moveTo(s * 0.24, s * 0.52)
          ..lineTo(s * 0.44, s * 0.70)
          ..lineTo(s * 0.76, s * 0.32);
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
    }
  }

  @override
  bool shouldRepaint(_StatusPainter old) => old.status != status;
}
