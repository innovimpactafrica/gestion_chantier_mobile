// widgets/home/overview_card_widget.dart
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/models/accueil.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/home/circular_progress.dart';
import 'package:gestion_chantier/moa/services/ProjetService.dart';
import 'package:gestion_chantier/moa/services/budget_service.dart';

class OverviewCardWidget extends StatelessWidget {
  final SiteStats siteStats;
  final double budgetPercentage;

  const OverviewCardWidget({
    super.key,
    required this.siteStats,
    required this.budgetPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vue d\'ensemble des chantiers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: HexColor('#2C3E50'),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: FutureBuilder<Map<String, int>>(
                  future:
                      RealEstateService().getAggregatedStatusKpiAllPromoters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 160,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              HexColor('#FF5C02'),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: HexColor('#E74C3C'),
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Erreur KPIs statut',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: HexColor('#E74C3C'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFallbackStatistics(),
                        ],
                      );
                    }

                    final data = snapshot.data ?? const {};
                    final enCours =
                        data['IN_PROGRESS'] ?? data['inProgress'] ?? 0;
                    final enRetard = data['DELAYED'] ?? data['delayed'] ?? 0;
                    final enAttente = data['PENDING'] ?? data['pending'] ?? 0;
                    final terminees =
                        data['COMPLETED'] ?? data['completed'] ?? 0;

                    return Column(
                      children: [
                        _buildStatRow('En cours', enCours, HexColor('#CBD5E1')),
                        const SizedBox(height: 10),
                        _buildStatRow(
                          'En retard',
                          enRetard,
                          HexColor('#E74C3C'),
                        ),
                        const SizedBox(height: 10),
                        _buildStatRow(
                          'En attente',
                          enAttente,
                          HexColor('#F39C12'),
                        ),
                        const SizedBox(height: 10),
                        _buildStatRow(
                          'Terminées',
                          terminees,
                          HexColor('#2ECC71'),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 62),

              FutureBuilder<double>(
                future:
                    BudgetService()
                        .getAggregatedConsumedPercentageAllPromoters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            HexColor('#FFF7F2'),
                          ),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: HexColor('#E74C3C'),
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Erreur\nbudget',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: HexColor('#E74C3C'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final consumed = snapshot.data ?? budgetPercentage;
                  return CircularProgressWidget(
                    percentage: consumed,
                    label: 'Budget\nconsommé',
                    value: '${consumed.toStringAsFixed(1)}%',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // _buildStatistics supprimé: les KPI agrégés remplacent l'ancien affichage

  Widget _buildFallbackStatistics() {
    return Column(
      children: [
        _buildStatRow('En cours', siteStats.inProgress, HexColor('#CBD5E1')),
        const SizedBox(height: 10),
        _buildStatRow('En retard', siteStats.delayed, HexColor('#E74C3C')),
        const SizedBox(height: 10),
        _buildStatRow('En attente', siteStats.pending, HexColor('#F39C12')),
        const SizedBox(height: 10),
        _buildStatRow('Terminées', siteStats.completed, HexColor('#2ECC71')),
      ],
    );
  }

  // _buildBudgetProgress supprimé: budget agrégé via FutureBuilder

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: HexColor('#7F8C8D'),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: HexColor('#34495E'),
          ),
        ),
      ],
    );
  }

  // _toDouble supprimé: non utilisé
}
