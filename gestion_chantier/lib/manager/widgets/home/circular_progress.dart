// widgets/home/circular_progress.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percentage;
  final String label;
  final String? value;

  const CircularProgressWidget({
    super.key,
    required this.percentage,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Donut ring with permanent gap at top
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutPainter(
                percentage: percentage.clamp(0.0, 100.0),
                progressColor: const Color(0xFFFF5C02),
                backgroundColor: const Color(0xFFFFECE3),
                strokeWidth: 22,
              ),
            ),
          ),

          // White center circle
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          // Center text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value ?? '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: HexColor('#2C3E50'),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: HexColor('#7F8C8D'),
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  // Gap in degrees kept at the top of the circle
  static const double _gapDeg = 22.0;

  const _DonutPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (diameter - strokeWidth) / 2;

    final gapRad = _gapDeg * pi / 180;
    // Start just after the gap (gap centered at 12 o'clock = -π/2)
    final startAngle = -pi / 2 + gapRad / 2;
    final totalSweep = 2 * pi - gapRad;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Background arc
    paint.color = backgroundColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      paint,
    );

    // Progress arc
    if (percentage > 0) {
      paint.color = progressColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        totalSweep * (percentage / 100),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.percentage != percentage;
}
