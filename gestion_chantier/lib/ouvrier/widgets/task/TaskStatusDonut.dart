import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../bloc/worker/TaskStatusDistributionBloc.dart';
import '../../bloc/worker/TaskStatusDistributionEvent.dart';
import '../../bloc/worker/TaskStatusDistributionState.dart';
import '../../models/TaskStatusDistribution.dart';
import '../../repository/task_repository.dart';
import '../../services/task_service.dart';

class TaskStatusDonut extends StatelessWidget {
  final int executorId;

  const TaskStatusDonut({Key? key, required this.executorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskStatusDistributionBloc(
        repository:
        TaskRepository(taskService: TaskService()),
      )..add(LoadTaskStatusDistribution(executorId)),
      child: BlocBuilder<TaskStatusDistributionBloc,
          TaskStatusDistributionState>(
        builder: (context, state) {
          if (state is TaskStatusDistributionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskStatusDistributionLoaded) {
            return _DonutChart(data: state.data);
          }

          if (state is TaskStatusDistributionError) {
            return Text(state.message,
                style: const TextStyle(color: Colors.red));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }






}


class _DonutChart extends StatelessWidget {
  final List<TaskStatusDistribution> data;

  const _DonutChart({required this.data});

  Color _color(String status) {
    switch (status) {
      case 'TODO':
        return const Color(0xFFE5E9F0);
      case 'IN_PROGRESS':
        return const Color(0xFFF2A93B);
      case 'DONE':
        return const Color(0xFF60C56E);
      case 'BLOCKED':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  String _label(String status) {
    switch (status) {
      case 'TODO':
        return 'À faire';
      case 'IN_PROGRESS':
        return 'En cours';
      case 'DONE':
        return 'Terminées';
      case 'BLOCKED':
        return 'En retard';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sections: data
                  .where((e) => e.percentage > 0)
                  .map(
                    (e) => PieChartSectionData(
                  value: e.percentage,
                  color: _color(e.status),
                  showTitle: false,
                  radius: 25,
                ),
              )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _color(e.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_label(e.status)} • ${e.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
