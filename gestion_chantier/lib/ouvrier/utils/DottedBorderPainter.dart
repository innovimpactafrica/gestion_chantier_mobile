import 'package:flutter/material.dart';

class DottedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final List<double> dashPattern;

  DottedBorderPainter({
    required this.radius,
    required this.color,
    required this.dashPattern,
    double? strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(radius),
          ),
        );

    final dashPath = Path();
    final dashWidth = dashPattern[0];
    final dashSpace = dashPattern[1];

    for (var metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
