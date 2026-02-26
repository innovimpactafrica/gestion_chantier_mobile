import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/ouvrier/utils/HexColor.dart';
import '../../bloc/worker/worker_dashboard_bloc.dart';
import '../../bloc/worker/worker_dashboard_event.dart';
import '../../bloc/worker/worker_dashboard_state.dart';
import '../../repository/worker_dashboard_repository.dart';
import '../../services/worker_service.dart';

class StatsGrid extends StatelessWidget {
  final int workerId;
  const StatsGrid({required this.workerId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkerDashboardBloc>(
      create:
          (_) => WorkerDashboardBloc(
            repository: WorkerDashboardRepository(
              workerService: WorkerService(),
            ),
          )..add(LoadWorkerDashboardEvent(workerId)),
      child: BlocBuilder<WorkerDashboardBloc, WorkerDashboardState>(
        builder: (context, state) {
          if (state is WorkerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkerDashboardLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StatCard(
                        value: '${state.dashboard.daysPresent}',
                        label: 'Jours présents',
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        value: '${state.dashboard.totalWorkedHours}',
                        label: 'Heures travaillées',
                        icon: Icons.schedule_outlined
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(
                        value: '${state.dashboard.completedTasks}',
                        label: 'Tâches terminées',
                          icon: Icons.task_alt
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        value: '${state.dashboard.performancePercentage}%',
                        label: 'Performance',
                          icon:Icons.insights_outlined
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is WorkerDashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Contenu principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFFFF5C02),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: HexColor('#777777'),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Icône en haut à droite
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                icon,
                size: 22,
                color: HexColor('#777777'),
              ),
            ),
          ],
        ),
      ),
    );
  }




}
