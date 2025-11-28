// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/repository/material_kpi_repository.dart';
import 'package:gestion_chantier/moa/repository/material_monthly_stats_repository.dart';
import 'package:gestion_chantier/moa/repository/material_top_used_repository.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/material_kpi/material_kpi_bloc.dart';
import 'package:gestion_chantier/moa/bloc/material_kpi/material_kpi_event.dart';
import 'package:gestion_chantier/moa/bloc/material_kpi/material_kpi_state.dart';
import 'package:gestion_chantier/moa/bloc/material_monthly_stats/material_monthly_stats_bloc.dart';
import 'package:gestion_chantier/moa/bloc/material_monthly_stats/material_monthly_stats_event.dart';
import 'package:gestion_chantier/moa/bloc/material_monthly_stats/material_monthly_stats_state.dart';
import 'package:gestion_chantier/moa/bloc/material_top_used/material_top_used_bloc.dart';
import 'package:gestion_chantier/moa/bloc/material_top_used/material_top_used_event.dart';
import 'package:gestion_chantier/moa/bloc/material_top_used/material_top_used_state.dart';
import 'package:gestion_chantier/moa/models/material_monthly_stat.dart';

class StatistiquesTab extends StatefulWidget {
  final RealEstateModel projet;
  const StatistiquesTab({super.key, required this.projet});

  @override
  _StatistiquesTabState createState() => _StatistiquesTabState();
}

class _StatistiquesTabState extends State<StatistiquesTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              MaterialKpiBloc(MaterialKpiRepository())
                ..add(FetchMaterialUnitDistribution(widget.projet.id)),
      child: BlocBuilder<MaterialKpiBloc, MaterialKpiState>(
        builder: (context, state) {
          Map<String, double> dataMap = {};
          if (state is MaterialKpiLoaded) {
            dataMap = state.distribution;
          }
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  if (state is MaterialKpiLoading)
                    Center(child: CircularProgressIndicator()),
                  if (state is MaterialKpiError)
                    Center(
                      child: Text(
                        'Erreur: [200m${state.message}[0m',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (state is MaterialKpiLoaded && dataMap.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Statistiques',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232323),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ce mois-ci',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF232323),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF232323),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: pc.PieChart(
                                  dataMap: dataMap,
                                  animationDuration: Duration(
                                    milliseconds: 800,
                                  ),
                                  chartType: pc.ChartType.disc,
                                  chartLegendSpacing: 0,
                                  chartRadius: 120,
                                  colorList: [
                                    Color(0xFF0084FF), // Bleu
                                    Color(0xFFB6E2A1), // Vert clair
                                    Color(0xFFFFC72C), // Jaune
                                    Color(0xFF1CA6A3), // Bleu canard
                                    Color(0xFFBFC3C7), // Gris
                                  ],
                                  legendOptions: pc.LegendOptions(
                                    showLegends: false,
                                  ),
                                  chartValuesOptions: pc.ChartValuesOptions(
                                    showChartValues: false,
                                  ),
                                ),
                              ),
                              SizedBox(width: 22),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < dataMap.length; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color:
                                                    [
                                                      Color(0xFF0084FF),
                                                      Color(0xFFB6E2A1),
                                                      Color(0xFFFFC72C),
                                                      Color(0xFF1CA6A3),
                                                      Color(0xFFBFC3C7),
                                                    ][i % 5],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                dataMap.keys.elementAt(i),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1A1A2C),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${dataMap.values.elementAt(i).round()}%',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (state is MaterialKpiLoaded && dataMap.isEmpty)
                    Center(
                      child: Text('Aucune donnée de distribution disponible.'),
                    ),
                  SizedBox(height: 32),
                  BlocProvider(
                    create:
                        (_) =>
                            MaterialTopUsedBloc(MaterialTopUsedRepository())
                              ..add(FetchMaterialTopUsed(widget.projet.id)),
                    child: BlocBuilder<
                      MaterialTopUsedBloc,
                      MaterialTopUsedState
                    >(
                      builder: (context, state) {
                        if (state is MaterialTopUsedLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is MaterialTopUsedError) {
                          return Center(
                            child: Text(
                              'Erreur: [200m[0m[200m${state.message}[0m',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (state is MaterialTopUsedLoaded) {
                          final materials = state.materials;
                          final barColors = [
                            Color(0xFFFDE7DC),
                            Color(0xFFCDB6E2),
                            Color(0xFFFF9685),
                            Color(0xFFFFE08A),
                            Color(0xFFA7E3C2),
                          ];
                          if (materials.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Aucune donnée de consommation mensuelle',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }
                          materials
                              .map((e) => e.totalUsedQuantity)
                              .reduce((a, b) => a > b ? a : b);
                          final maxY = 350.0;
                          return Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Consommation mensuelle',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF232323),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 18),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY,
                                      minY: 0,
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipColor:
                                              (group) => Colors.black87,
                                          getTooltipItem: (
                                            group,
                                            groupIndex,
                                            rod,
                                            rodIndex,
                                          ) {
                                            String label = '';
                                            if (group.x >= 0 &&
                                                group.x < materials.length) {
                                              label =
                                                  materials[group.x]
                                                      .materialLabel;
                                            }
                                            return BarTooltipItem(
                                              '$label\n${rod.toY.toInt()}',
                                              TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 50,
                                        getDrawingHorizontalLine: (value) {
                                          if (value % 50 == 0 &&
                                              value >= -50 &&
                                              value <= 400) {
                                            return FlLine(
                                              color: Color(0xFFF5F5F5),
                                              strokeWidth: 1.3,
                                            );
                                          }
                                          return FlLine(
                                            color: Colors.transparent,
                                            strokeWidth: 0,
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              if (value % 50 == 0 &&
                                                  value <= maxY) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 1.0,
                                                      ),
                                                  child: Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF999999),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return SizedBox.shrink();
                                            },
                                            interval: 50,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 25,
                                            getTitlesWidget: (value, meta) {
                                              int idx = value.toInt();
                                              if (idx >= 0 &&
                                                  idx < materials.length) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 1,
                                                  ),
                                                  child: Text(
                                                    materials[idx]
                                                        .materialLabel,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }
                                              return Text('');
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      barGroups: [
                                        for (
                                          int i = 0;
                                          i < materials.length;
                                          i++
                                        )
                                          BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY:
                                                    materials[i]
                                                        .totalUsedQuantity,
                                                color:
                                                    barColors[i %
                                                        barColors.length],
                                                width: 44,
                                                borderRadius: BorderRadius.zero,
                                                backDrawRodData:
                                                    BackgroundBarChartRodData(
                                                      show: true,
                                                      toY: 0,
                                                      color: barColors[i %
                                                              barColors.length]
                                                          .withOpacity(0.08),
                                                    ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18),
                                Center(
                                  child: Text(
                                    'Top 5 matériaux les plus utilisés',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    margin: EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Évolution mensuelle',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF232323),
                          ),
                        ),

                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 10,

                              decoration: BoxDecoration(
                                color: Color(0xFF14BA6D).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              margin: EdgeInsets.only(right: 10),
                            ),
                            Text(
                              'Unité utilisés',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF232323),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: BlocProvider(
                            create:
                                (_) => MaterialMonthlyStatsBloc(
                                  MaterialMonthlyStatsRepository(),
                                )..add(
                                  FetchMaterialMonthlyStats(widget.projet.id),
                                ),
                            child: BlocBuilder<
                              MaterialMonthlyStatsBloc,
                              MaterialMonthlyStatsState
                            >(
                              builder: (context, state) {
                                if (state is MaterialMonthlyStatsLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is MaterialMonthlyStatsError) {
                                  return Center(
                                    child: Text(
                                      'Erreur: ${state.message}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (state
                                    is MaterialMonthlyStatsLoaded) {
                                  final stats = state.stats;
                                  final now = DateTime.now();
                                  final year = now.year;
                                  final allMonths = List.generate(
                                    12,
                                    (i) =>
                                        '${(i + 1).toString().padLeft(2, '0')}-$year',
                                  );
                                  List<double> values = [];
                                  List<String> months = [];
                                  for (final m in allMonths) {
                                    final stat = stats.firstWhere(
                                      (s) => s.date == m,
                                      orElse:
                                          () => MaterialMonthlyStat(
                                            date: m,
                                            totalEntries: 0,
                                            totalExits: 0,
                                          ),
                                    );
                                    values.add(stat.totalEntries.toDouble());
                                    months.add(m);
                                  }
                                  final maxData =
                                      values.isNotEmpty
                                          ? values.reduce(
                                            (a, b) => a > b ? a : b,
                                          )
                                          : 0.0;
                                  final maxY =
                                      ((maxData / 10).ceil() * 10)
                                          .clamp(10, double.infinity)
                                          .toDouble();
                                  return LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: 11,
                                      minY: 0,
                                      maxY: maxY,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 50,
                                        verticalInterval: 1,
                                        getDrawingHorizontalLine:
                                            (value) => FlLine(
                                              color: Color(0xFFF3F4F6),
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 36,
                                            getTitlesWidget: (value, meta) {
                                              if (value % 50 == 0 &&
                                                  value >= 0 &&
                                                  value <= maxY) {
                                                return Text(
                                                  value.toInt().toString(),
                                                  style: TextStyle(
                                                    color: Color(0xFFB0B0B0),
                                                    fontSize: 13,
                                                  ),
                                                );
                                              }
                                              return SizedBox.shrink();
                                            },
                                            interval: 50,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int idx = value.round();
                                              if (idx >= 0 &&
                                                  idx < months.length) {
                                                final m = months[idx];
                                                final mois = [
                                                  'Jan',
                                                  'Fev',
                                                  'Mars',
                                                  'Avr',
                                                  'Mai',
                                                  'Juin',
                                                  'Juil',
                                                  'Aout',
                                                  'Sept',
                                                  'Oct',
                                                  'Nov',
                                                  'Dec',
                                                ];
                                                final parts = m.split('-');
                                                final mIdx =
                                                    int.tryParse(parts[0]) ?? 1;
                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  child: Text(
                                                    mois[mIdx - 1],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFFB0B0B0),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Text('');
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          isCurved: true,
                                          color: Color(0xFFFF7A00),
                                          barWidth: 2,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (spot, percent, bar, idx) =>
                                                    FlDotCirclePainter(
                                                      color: Colors.white,
                                                      strokeColor: Color(
                                                        0xFFFF7A00,
                                                      ),
                                                      strokeWidth: 2,
                                                      radius: 4,
                                                    ),
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Color(
                                              0xFFFF7A00,
                                            ).withOpacity(0.12),
                                          ),
                                          spots: [
                                            for (
                                              int i = 0;
                                              i < values.length;
                                              i++
                                            )
                                              FlSpot(i.toDouble(), values[i]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Cas par défaut : courbe plate à 0 sur 12 mois
                                  final now = DateTime.now();
                                  final year = now.year;
                                  final months = List.generate(
                                    12,
                                    (i) =>
                                        '${(i + 1).toString().padLeft(2, '0')}-$year',
                                  );
                                  final zeros = List.filled(12, 0.0);
                                  return LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: 11,
                                      minY: 0,
                                      maxY: 100,
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval: 50,
                                        verticalInterval: 1,
                                        getDrawingHorizontalLine:
                                            (value) => FlLine(
                                              color: Color(0xFFF3F4F6),
                                              strokeWidth: 1,
                                            ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 36,
                                            getTitlesWidget:
                                                (value, meta) => Text(
                                                  value.toInt().toString(),
                                                  style: TextStyle(
                                                    color: Color(0xFFB0B0B0),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                            interval: 50,
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int idx = value.round();
                                              if (idx >= 0 &&
                                                  idx < months.length) {
                                                final m = months[idx];
                                                final mois = [
                                                  'Jan',
                                                  'Fev',
                                                  'Mars',
                                                  'Avr',
                                                  'Mai',
                                                  'Juin',
                                                  'Juil',
                                                  'Aout',
                                                  'Sept',
                                                  'Oct',
                                                  'Nov',
                                                  'Dec',
                                                ];
                                                final parts = m.split('-');
                                                final mIdx =
                                                    int.tryParse(parts[0]) ?? 1;
                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  child: Text(
                                                    mois[mIdx - 1],
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFFB0B0B0),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Text('');
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          isCurved: true,
                                          color: Color(0xFFFF7A00),
                                          barWidth: 2,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter:
                                                (spot, percent, bar, idx) =>
                                                    FlDotCirclePainter(
                                                      color: Colors.white,
                                                      strokeColor: Color(
                                                        0xFFFF7A00,
                                                      ),
                                                      strokeWidth: 2,
                                                      radius: 4,
                                                    ),
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Color(
                                              0xFFFF7A00,
                                            ).withOpacity(0.12),
                                          ),
                                          spots: [
                                            for (
                                              int i = 0;
                                              i < zeros.length;
                                              i++
                                            )
                                              FlSpot(i.toDouble(), zeros[i]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
