import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SpendsDonutChart extends StatelessWidget {
  final Map<String, double> categories;

  const SpendsDonutChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final double total = categories.values.fold(0, (sum, val) => sum + val);

    return AspectRatio(
      aspectRatio: 1.2,
      child: CustomPaint(
        painter: DonutChartPainter(categories: categories, total: total),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> categories;
  final double total;

  DonutChartPainter({required this.categories, required this.total});

  final List<Color> palette = const [
    AppColors.indigo,
    AppColors.mint,
    AppColors.rose,
    AppColors.categoryPrintouts,
    AppColors.categoryUdhar,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 16;
    final strokeWidth = radius * 0.32;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;
    int index = 0;

    categories.forEach((_, amount) {
      final sweepAngle = (amount / total) * 2 * pi;
      paint.color = palette[index % palette.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}