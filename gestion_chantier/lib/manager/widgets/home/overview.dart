// widgets/home/overview_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/Task/task_state.dart';
import 'package:gestion_chantier/manager/bloc/budget/budget_bloc.dart';
import 'package:gestion_chantier/manager/bloc/budget/budget_state.dart';
import 'package:gestion_chantier/manager/bloc/task/task_bloc.dart';
import 'package:gestion_chantier/manager/models/accueil.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/home/circular_progress.dart';

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
      padding: const EdgeInsets.all(15),
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
              // Statistics avec données réelles
              Expanded(
                flex: 2,
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    return _buildStatistics(state);
                  },
                ),
              ),

              const SizedBox(width: 62),

              // Budget Progress avec données réelles
              BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  return _buildBudgetProgress(state);
                },
              ),
            ],
          ),

          // Section budget détaillée
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatistics(TaskState state) {
    if (state is TaskLoading) {
      return SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HexColor('#FF5C02')),
          ),
        ),
      );
    }

    if (state is TaskLoaded) {
      final taskModel = state.taskModel;
      return Column(
        children: [
          _buildStatRow(
            'En cours',
            taskModel.pendingTasks,
            HexColor('#CBD5E1'),
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            'En retard',
            taskModel.overdueTasks,
            HexColor('#E74C3C'),
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            'En attente',
            taskModel.pendingTasks,
            HexColor('#F39C12'),
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            'Terminées',
            taskModel.completedTasks,
            HexColor('#2ECC71'),
          ),
        ],
      );
    }

    if (state is TaskError) {
      return Column(
        children: [
          Icon(Icons.error_outline, color: HexColor('#E74C3C'), size: 30),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement\ndes statistiques',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: HexColor('#E74C3C'),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Afficher les données de fallback
          _buildFallbackStatistics(),
        ],
      );
    }

    // État initial - afficher les données mockées
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

  Widget _buildBudgetProgress(BudgetState state) {
    if (state is BudgetLoading) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HexColor('#FFF7F2')),
          ),
        ),
      );
    }

    if (state is BudgetDashboardLoaded) {
      final data = state.dashboardData;
      final consumedPercentage = _toDouble(data['consumedPercentage'] ?? 0);

      return CircularProgressWidget(
        percentage: consumedPercentage,
        label: 'Budget\nconsommé',
        value: '${consumedPercentage.toStringAsFixed(1)}%',
      );
    }

    if (state is BudgetError) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: HexColor('#E74C3C'), size: 30),
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

    // État initial - afficher les données mockées
    return CircularProgressWidget(
      percentage: budgetPercentage,
      label: 'Budget\nconsommé',
    );
  }

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

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
