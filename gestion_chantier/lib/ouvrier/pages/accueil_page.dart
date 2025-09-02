import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/ouvrier/widgets/home/UserNameSection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_bloc.dart';
import 'package:gestion_chantier/ouvrier/repository/auth_repository.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_event.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_state.dart';
import '../widgets/home/stats_grid.dart';
import '../bloc/worker/worker_tasks_bloc.dart';
import '../bloc/worker/worker_tasks_event.dart';
import '../bloc/worker/worker_tasks_state.dart';
import '../repository/task_repository.dart';
import '../services/task_service.dart';
import '../models/TaskModel.dart';
import 'taches_page.dart';

class AccueilOuvrierPage extends StatelessWidget {
  final VoidCallback onVoirPlus;
  const AccueilOuvrierPage({Key? key, required this.onVoirPlus})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderSection(),
            Transform.translate(
              offset: Offset(0, -30),
              child: const _WelcomeCard(),
            ),
            BlocProvider<UserNameSectionBloc>(
              create:
                  (_) =>
                      UserNameSectionBloc(authRepository: AuthRepository())
                        ..add(LoadCurrentUserEvent()),
              child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
                builder: (context, state) {
                  if (state is UserNameLoaded) {
                    return StatsGrid(workerId: state.user.id);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            _TodayTasksSection(onVoirPlus: onVoirPlus),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, state) {
          final userProfile =
              state is UserNameLoaded ? state.user.profil : 'Ouvrier';

          return Container(
            height: 170, // hauteur fixe moderne
            decoration: BoxDecoration(color: HexColor('#1A365D')),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/avatar1.png'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const UserNameSection(),
                      Text(
                        userProfile,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.60),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 10,
                      top: 12,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF5C02),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, state) {
          String nom = '';
          String prenom = '';
          if (state is UserNameLoading) {
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (state is UserNameLoaded) {
            nom = state.user.nom;
            prenom = state.user.prenom;
          } else if (state is UserNameError) {
            return Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            );
          } else {
            nom = 'Invité';
            prenom = '';
          }
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $prenom $nom',
                  style: const TextStyle(
                    color: Color(0xFF183B63),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Voici votre activité pour aujourd'hui",
                  style: TextStyle(
                    color: Color(0xFF8A98A8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayTasksSection extends StatelessWidget {
  final VoidCallback onVoirPlus;
  const _TodayTasksSection({required this.onVoirPlus});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, state) {
          if (state is UserNameLoaded) {
            final workerId = state.user.id;
            return BlocProvider<WorkerTasksBloc>(
              create:
                  (_) => WorkerTasksBloc(
                    repository: TaskRepository(taskService: TaskService()),
                  )..add(LoadWorkerTasksEvent(workerId)),
              child: BlocBuilder<WorkerTasksBloc, WorkerTasksState>(
                builder: (context, taskState) {
                  if (taskState is WorkerTasksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (taskState is WorkerTasksLoaded) {
                    final tasks =
                        taskState.tasks
                            .where((t) => t.status != 'DONE')
                            .toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tâches aujourd'hui",
                                style: TextStyle(
                                  color: HexColor('#2C3E50'),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              GestureDetector(
                                onTap: onVoirPlus,
                                child: Text(
                                  'Voir plus',
                                  style: TextStyle(
                                    color: Color(0xFFFF5C02),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          ...tasks
                              .take(2)
                              .map(
                                (task) => Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),
                                          builder:
                                              (_) => TaskDetailBottomSheet(
                                                task: task,
                                              ),
                                        );
                                      },
                                      child: _TaskCard(
                                        title: task.title,
                                        time: _formatTaskDate(task),
                                        status: _mapStatus(task.status),
                                        priority: _mapPriority(task.priority),
                                        priorityColor: _priorityColor(
                                          task.priority,
                                        ),
                                        actionLabel: _actionLabel(task.status),
                                        actionColor: const Color(0xFFFF5C02),
                                        actionIcon: _actionIcon(task.status),
                                        actionType: _actionType(task.status),
                                        onAction: () async {
                                          final isTodo = task.status == 'TODO';
                                          final action =
                                              isTodo ? 'commencer' : 'terminer';
                                          final confirmed =
                                              await showModalBottomSheet<bool>(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder:
                                                    (_) =>
                                                        TaskActionConfirmBottomSheet(
                                                          action: action,
                                                        ),
                                              );
                                          if (confirmed == true) {
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder:
                                                  (_) =>
                                                      TaskActionCompleteBottomSheet(
                                                        taskTitle: task.title,
                                                        action: action,
                                                      ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    );
                  } else if (taskState is WorkerTasksError) {
                    return Center(
                      child: Text(
                        taskState.message,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
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

String _mapStatus(String status) {
  switch (status) {
    case 'TODO':
      return 'En attente';
    case 'IN_PROGRESS':
      return 'En cours';
    case 'DONE':
      return 'Terminé';
    default:
      return status;
  }
}

String _mapPriority(String priority) {
  switch (priority) {
    case 'HIGH':
      return 'Haute';
    case 'MEDIUM':
      return 'Moyenne';
    case 'LOW':
      return 'Faible';
    default:
      return priority;
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'HIGH':
      return const Color(0xFFFF3B30);
    case 'MEDIUM':
      return const Color(0xFFFFA726);
    case 'LOW':
      return const Color(0xFF4CAF50);
    default:
      return const Color(0xFF8A98A8);
  }
}

String _actionLabel(String status) {
  switch (status) {
    case 'TODO':
      return 'Commencer';
    case 'IN_PROGRESS':
      return 'Terminé';
    case 'DONE':
      return 'Fait';
    default:
      return '';
  }
}

IconData _actionIcon(String status) {
  switch (status) {
    case 'TODO':
      return Icons.play_arrow;
    case 'IN_PROGRESS':
      return Icons.check;
    case 'DONE':
      return Icons.check_circle;
    default:
      return Icons.help;
  }
}

_TaskActionType _actionType(String status) {
  switch (status) {
    case 'TODO':
      return _TaskActionType.start;
    case 'IN_PROGRESS':
    case 'DONE':
      return _TaskActionType.done;
    default:
      return _TaskActionType.start;
  }
}

enum _TaskActionType { done, start }

String _formatTaskDate(TaskModel task) {
  if (task.startDate != null && task.endDate != null) {
    final start = task.startDate!;
    final end = task.endDate!;
    String startStr =
        "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}";
    String endStr =
        "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";
    return "$startStr - $endStr";
  }
  return '';
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String priority;
  final Color priorityColor;
  final String actionLabel;
  final Color actionColor;
  final IconData actionIcon;
  final _TaskActionType actionType;
  final VoidCallback onAction;

  const _TaskCard({
    required this.title,
    required this.time,
    required this.status,
    required this.priority,
    required this.priorityColor,
    required this.actionLabel,
    required this.actionColor,
    required this.actionIcon,
    required this.actionType,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: HexColor('#34495E'),
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                priority,
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: HexColor('#6C757D')),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(color: HexColor('#6C757D'), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HexColor('#F1F2F6'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: HexColor('#6B7280'),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                onPressed: onAction,
                icon: Icon(actionIcon, size: 20, color: Colors.white),
                label: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
