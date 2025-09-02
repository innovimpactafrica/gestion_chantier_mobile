import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class StudiesDistributionChart extends StatelessWidget {
  final double pendingPct;
  final double inProgressPct;
  final double validatedPct;
  final double rejectedPct;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const StudiesDistributionChart({
    super.key,
    required this.pendingPct,
    required this.inProgressPct,
    required this.validatedPct,
    required this.rejectedPct,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition des études (%)',
                style: TextStyle(
                  color: HexColor('#2C3E50'),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _PeriodPill(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 55.0),
            child: SizedBox(
              height: 200,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(
                  painter: _DonutPainter(
                    pendingPct: pendingPct,
                    inProgressPct: inProgressPct,
                    validatedPct: validatedPct,
                    rejectedPct: rejectedPct,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _Legend(
                  color: HexColor('#FF7A00'),
                  label: 'Attente • ${pendingPct.toStringAsFixed(1)}%',
                ),

                _Legend(
                  color: HexColor('#2D72FE'),
                  label: 'En cours • ${inProgressPct.toStringAsFixed(1)}%',
                ),
                _Legend(
                  color: HexColor('#18C161'),
                  label: 'Validées • ${validatedPct.toStringAsFixed(1)}%',
                ),
                _Legend(
                  color: HexColor('#FF3D3D'),
                  label: 'Rejetées • ${rejectedPct.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const _PeriodPill({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 'Ce mois', child: Text('Ce mois')),
            PopupMenuItem(value: 'Aujourd\'hui', child: Text('Aujourd\'hui')),
            PopupMenuItem(value: 'Hier', child: Text('Hier')),
            PopupMenuItem(value: 'Cette semaine', child: Text('Cette semaine')),
          ],
      onSelected: onPeriodChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: HexColor('#E2E8F0')),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedPeriod,
              style: TextStyle(color: HexColor('#1A202C').withOpacity(0.6)),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: HexColor('#1A202C').withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: HexColor('#777777'),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double pendingPct;
  final double inProgressPct;
  final double validatedPct;
  final double rejectedPct;

  _DonutPainter({
    required this.pendingPct,
    required this.inProgressPct,
    required this.validatedPct,
    required this.rejectedPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final double startAngle = -90 * 3.1415926535 / 180;
    final double sweepPending = 2 * 3.1415926535 * (pendingPct / 100);
    final double sweepInProgress = 2 * 3.1415926535 * (inProgressPct / 100);
    final double sweepValidated = 2 * 3.1415926535 * (validatedPct / 100);
    final double sweepRejected = 2 * 3.1415926535 * (rejectedPct / 100);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.14
          ..strokeCap = StrokeCap.butt;

    double current = startAngle;

    paint.color = HexColor('#FF7A00');
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepPending,
      false,
      paint,
    );
    current += sweepPending;

    paint.color = HexColor('#2D72FE');
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepInProgress,
      false,
      paint,
    );
    current += sweepInProgress;

    paint.color = HexColor('#18C161');
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepValidated,
      false,
      paint,
    );
    current += sweepValidated;

    paint.color = HexColor('#FF3D3D');
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepRejected,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return pendingPct != oldDelegate.pendingPct ||
        inProgressPct != oldDelegate.inProgressPct ||
        validatedPct != oldDelegate.validatedPct ||
        rejectedPct != oldDelegate.rejectedPct;
  }
}
