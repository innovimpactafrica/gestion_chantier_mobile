import 'package:flutter/material.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';

class DistributionChartSection extends StatelessWidget {
  final BetStudyKpiModel? kpiData;

  const DistributionChartSection({super.key, this.kpiData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition des dossiers (%)',
                style: TextStyle(
                  color: HexColor('#2C3E50'),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _PeriodPill(),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 200,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(
                  painter: _DonutPainter(
                    pendingPct: kpiData?.pendingPercentage ?? 0.0,
                    inProgressPct: kpiData?.inProgressPercentage ?? 0.0,
                    deliveredPct: kpiData?.deliveredPercentage ?? 0.0,
                    validatedPct: kpiData?.validatedPercentage ?? 0.0,
                    rejectedPct: kpiData?.rejectedPercentage ?? 0.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Légende en format 2x3 (2 colonnes, 3 lignes)
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _LegendItem(
                      color: HexColor('#FF9800'),
                      label: 'Attente',
                      percentage:
                          '${(kpiData?.pendingPercentage ?? 0.0).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: HexColor('#2196F3'),
                      label: 'En cours',
                      percentage:
                          '${(kpiData?.inProgressPercentage ?? 0.0).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: HexColor('#4F5AED'),
                      label: 'Livrées',
                      percentage:
                          '${(kpiData?.deliveredPercentage ?? 0.0).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _LegendItem(
                      color: HexColor('#4CAF50'),
                      label: 'Validées',
                      percentage:
                          '${(kpiData?.validatedPercentage ?? 0.0).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: HexColor('#F44336'),
                      label: 'Rejetées',
                      percentage:
                          '${(kpiData?.rejectedPercentage ?? 0.0).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12), // Espace pour équilibrer
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: 'Ce mois', child: Text('Ce mois')),
            const PopupMenuItem(
              value: 'Aujourd\'hui',
              child: Text('Aujourd\'hui'),
            ),
            const PopupMenuItem(value: 'Hier', child: Text('Hier')),
            const PopupMenuItem(
              value: 'Cette semaine',
              child: Text('Cette semaine'),
            ),
          ],
      onSelected: (value) {
        // TODO: Implémenter la logique de changement de période
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: HexColor('#D1D5DB')),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ce mois',
              style: TextStyle(
                color: HexColor('#1A202C').withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: HexColor('#1A202C').withOpacity(0.6),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: HexColor('#2C3E50'),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: HexColor('#7F8C8D'),
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
  final double deliveredPct;
  final double validatedPct;
  final double rejectedPct;

  _DonutPainter({
    required this.pendingPct,
    required this.inProgressPct,
    required this.deliveredPct,
    required this.validatedPct,
    required this.rejectedPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final double startAngle = -90 * 3.1415926535 / 180;
    final double sweepPending = 2 * 3.1415926535 * (pendingPct / 100);
    final double sweepInProgress = 2 * 3.1415926535 * (inProgressPct / 100);
    final double sweepDelivered = 2 * 3.1415926535 * (deliveredPct / 100);
    final double sweepValidated = 2 * 3.1415926535 * (validatedPct / 100);
    final double sweepRejected = 2 * 3.1415926535 * (rejectedPct / 100);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.14
          ..strokeCap = StrokeCap.butt;

    double current = startAngle;

    paint.color = HexColor('#FF9800'); // Orange pour Attente
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepPending,
      false,
      paint,
    );
    current += sweepPending;

    paint.color = HexColor('#2196F3'); // Bleu pour En cours
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepInProgress,
      false,
      paint,
    );
    current += sweepInProgress;

    paint.color = HexColor('#4F5AED'); // Violet pour Livrées
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepDelivered,
      false,
      paint,
    );
    current += sweepDelivered;

    paint.color = HexColor('#4CAF50'); // Vert pour Validées
    canvas.drawArc(
      rect.deflate(size.shortestSide * 0.18),
      current,
      sweepValidated,
      false,
      paint,
    );
    current += sweepValidated;

    paint.color = HexColor('#F44336'); // Rouge pour Rejetées
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
        deliveredPct != oldDelegate.deliveredPct ||
        validatedPct != oldDelegate.validatedPct ||
        rejectedPct != oldDelegate.rejectedPct;
  }
}
