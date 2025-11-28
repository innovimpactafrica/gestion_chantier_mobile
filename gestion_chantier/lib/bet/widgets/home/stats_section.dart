import 'package:flutter/material.dart';
import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  final BetStudyKpiModel? kpiData;

  const StatsSection({super.key, this.kpiData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: kpiData?.pendingCount.toString() ?? '0',
                  label: 'Études en attente',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  value: kpiData?.inProgressCount.toString() ?? '0',
                  label: 'Études en cours',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: kpiData?.validatedCount.toString() ?? '0',
                  label: 'Études validées',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  value: kpiData?.rejectedCount.toString() ?? '0',
                  label: 'Études rejetées',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
