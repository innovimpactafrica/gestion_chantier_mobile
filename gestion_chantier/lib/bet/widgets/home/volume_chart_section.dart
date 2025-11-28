import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';
import 'package:gestion_chantier/bet/models/VolumetryModel.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';

class VolumeChartSection extends StatelessWidget {
  final BetStudyKpiModel? kpiData;
  final BetVolumetryModel? volumetryData;

  const VolumeChartSection({super.key, this.kpiData, this.volumetryData});

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
                'Volumétrie',
                style: TextStyle(
                  color: HexColor('#2C3E50'),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _PeriodPill(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 60,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          'Projets concernés',
                          'Demandes reçues',
                          'Rapports produits',
                        ];
                        return Text(
                          titles[value.toInt()],
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#6C757D'),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: HexColor('#6C757D'),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 0.5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: HexColor('#E9ECEF'), strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    // Afficher les 2 lignes verticales qui séparent les 3 catégories
                    // Ligne entre "Projets concernés" et "Demandes reçues" (position 0.5)
                    // Ligne entre "Demandes reçues" et "Rapports produits" (position 1.5)
                    if ((value - 0.5).abs() < 0.1 ||
                        (value - 1.5).abs() < 0.1) {
                      return FlLine(color: HexColor('#E9ECEF'), strokeWidth: 1);
                    }
                    return FlLine(color: Colors.transparent, strokeWidth: 0);
                  },
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY:
                            (volumetryData?.totalStudyRequests ?? 0).toDouble(),
                        color: HexColor('#6699FF'),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY:
                            (volumetryData?.distinctPropertiesCount ?? 0)
                                .toDouble(),
                        color: HexColor('#6699FF'),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: (volumetryData?.totalReports ?? 0).toDouble(),
                        color: HexColor('#6699FF'),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: HexColor('#1A202C').withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
