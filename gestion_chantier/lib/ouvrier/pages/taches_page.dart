import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/ouvrier/utils/DottedBorderPainter.dart';
import '../bloc/username/user_name_section_bloc.dart';
import '../bloc/username/user_name_section_event.dart';
import '../bloc/username/user_name_section_state.dart';
import '../repository/auth_repository.dart';
import '../bloc/worker/worker_tasks_bloc.dart';
import '../bloc/worker/worker_tasks_event.dart';
import '../bloc/worker/worker_tasks_state.dart';
import '../repository/task_repository.dart';
import '../services/task_service.dart';
import '../models/TaskModel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TachesPage extends StatefulWidget {
  const TachesPage({Key? key}) : super(key: key);

  @override
  State<TachesPage> createState() => _TachesPageState();
}

class _TachesPageState extends State<TachesPage> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'Toutes',
    'En attente',
    'En cours',
    'Terminées',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor('#F1F2F6'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TachesHeader(),
          const SizedBox(height: 10),
          _TachesFilters(
            filters: _filters,
            selected: _selectedFilter,
            onChanged: (i) => setState(() => _selectedFilter = i),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: BlocProvider<UserNameSectionBloc>(
              create:
                  (_) =>
                      UserNameSectionBloc(authRepository: AuthRepository())
                        ..add(LoadCurrentUserEvent()),
              child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
                builder: (context, userState) {
                  if (userState is UserNameLoaded) {
                    final workerId = userState.user.id;
                    return BlocProvider<WorkerTasksBloc>(
                      create:
                          (_) => WorkerTasksBloc(
                            repository: TaskRepository(
                              taskService: TaskService(),
                            ),
                          )..add(LoadWorkerTasksEvent(workerId)),
                      child: BlocBuilder<WorkerTasksBloc, WorkerTasksState>(
                        builder: (context, taskState) {
                          if (taskState is WorkerTasksLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (taskState is WorkerTasksLoaded) {
                            final tasks = _filterTasks(
                              taskState.tasks,
                              _selectedFilter,
                            );
                            if (tasks.isEmpty) {
                              return const Center(
                                child: Text('Aucune tâche trouvée.'),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: tasks.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, i) {
                                final task = tasks[i];
                                return _TacheCard(
                                  title: task.title,
                                  time: _formatTaskDate(task),
                                  status: _mapStatus(task.status),
                                  statusColor: _statusColor(task.status),
                                  priority: _mapPriority(task.priority),
                                  priorityColor: _priorityColor(task.priority),
                                  actionLabel: _actionLabel(task.status),
                                  actionColor: const Color(0xFFFF5C02),
                                  actionIcon: _actionIcon(task.status),
                                  taskModel: task,
                                  onStatusChanged: () {
                                    // Rafraîchir le bloc
                                    final workerId =
                                        task.executors.isNotEmpty
                                            ? task.executors[0].id
                                            : null;
                                    if (workerId != null) {
                                      BlocProvider.of<WorkerTasksBloc>(
                                        context,
                                      ).add(LoadWorkerTasksEvent(workerId));
                                    }
                                  },
                                );
                              },
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
                  } else if (userState is UserNameError) {
                    return Center(
                      child: Text(
                        userState.message,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<TaskModel> _filterTasks(List<TaskModel> tasks, int selectedFilter) {
  switch (selectedFilter) {
    case 1:
      return tasks.where((t) => t.status == 'TODO').toList();
    case 2:
      return tasks.where((t) => t.status == 'IN_PROGRESS').toList();
    case 3:
      return tasks.where((t) => t.status == 'DONE').toList();
    default:
      return tasks;
  }
}

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

String _mapStatus(String status) {
  switch (status) {
    case 'TODO':
      return 'En attente';
    case 'IN_PROGRESS':
      return 'En cours';
    case 'DONE':
      return 'Terminée';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'DONE':
      return const Color(0xFFB7F5C5);
    default:
      return const Color(0xFFBFC5D2);
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
      return const Color(0xFF2ECC71);
    default:
      return const Color(0xFF8A98A8);
  }
}

String _actionLabel(String status) {
  switch (status) {
    case 'TODO':
      return 'Commencer';
    case 'IN_PROGRESS':
      return 'Terminer';
    case 'DONE':
      return '';
    default:
      return '';
  }
}

IconData? _actionIcon(String status) {
  switch (status) {
    case 'TODO':
      return Icons.play_arrow;
    case 'IN_PROGRESS':
      return Icons.check;
    default:
      return null;
  }
}

class _TachesHeader extends StatelessWidget {
  const _TachesHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: HexColor('#1A365D')),
      padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Mes Tâches',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _TachesFilters extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onChanged;
  const _TachesFilters({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isActive = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color:
                      isActive ? HexColor('#FF5C02') : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : HexColor('#1A365D'),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TacheCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String actionLabel;
  final Color actionColor;
  final IconData? actionIcon;
  final TaskModel? taskModel;
  final VoidCallback? onStatusChanged;
  const _TacheCard({
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.actionLabel,
    required this.actionColor,
    required this.actionIcon,
    this.taskModel,
    this.onStatusChanged,
  });

  Future<void> _handleAction(BuildContext context) async {
    if (taskModel == null) return;
    final isTodo = taskModel!.status == 'TODO';
    final action = isTodo ? 'commencer' : 'terminer';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActionConfirmBottomSheet(action: action),
    );
    if (confirmed == true) {
      // Appel API pour changer le statut
      final nextStatus = isTodo ? 'IN_PROGRESS' : 'DONE';
      await TaskService().updateTaskStatus(taskModel!.id, nextStatus);
      if (onStatusChanged != null) onStatusChanged!();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Statut mis à jour !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Terminée';
    final isInProgress = status == 'En cours';
    final isTodo = status == 'En attente';
    return GestureDetector(
      onTap:
          taskModel != null
              ? () {
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
                        task: taskModel!,
                        onStatusChanged: onStatusChanged,
                      ),
                );
              }
              : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
                    style: const TextStyle(
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF8A98A8),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF8A98A8),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Terminée',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color:
                            status == 'Terminée'
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFF8A98A8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const Spacer(),
                if (isTodo)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _handleAction(context),
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Commencer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  )
                else if (isInProgress)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _handleAction(context),
                    icon: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Terminé',
                      style: TextStyle(
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
      ),
    );
  }
}

class TaskDetailBottomSheet extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onStatusChanged;
  const TaskDetailBottomSheet({
    Key? key,
    required this.task,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  bool _loading = false;
  String? _error;
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await TaskService().fetchTaskDetail(widget.task.id);
      setState(() {
        _task = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement du détail de la tâche';
        _loading = false;
        _task = widget.task;
      });
    }
  }

  Future<void> _confirmAndChangeStatus(BuildContext context) async {
    final isTodo = _task.status == 'TODO';
    final _ = _task.status == 'IN_PROGRESS';
    final action = isTodo ? 'commencer' : 'terminer';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActionConfirmBottomSheet(action: action),
    );
    if (confirmed == true) {
      final result = await showModalBottomSheet<TaskActionCompleteResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => TaskActionCompleteBottomSheet(
              taskTitle: _task.title,
              action: action,
            ),
      );
      if (result != null) {
        await _changeStatus(context);
        // Ici tu peux utiliser result.comment et result.photos pour l'upload
        print('Commentaire: ${result.comment}');
        print('Photos: ${result.photos}');
      }
    }
  }

  Future<void> _changeStatus(BuildContext context) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    String nextStatus = _task.status == 'TODO' ? 'IN_PROGRESS' : 'DONE';
    try {
      await TaskService().updateTaskStatus(_task.id, nextStatus);
      Navigator.of(context).pop();
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Statut mis à jour !')));
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du changement de statut';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    print('[DEBUG] Modal superviseur:  [32m${_task.promoterName} [0m');
    final isInProgress = _task.status == 'IN_PROGRESS';
    final isTodo = _task.status == 'TODO';
    final _ = _task.status == 'DONE';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _task.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _task.status == 'DONE'
                                ? const Color(0xFFE8F8F1)
                                : const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _mapStatus(_task.status),
                        style: TextStyle(
                          color:
                              _task.status == 'DONE'
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFF8A98A8),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _task.description,
                    style: const TextStyle(
                      color: Color(0xFF8A98A8),
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFF5C02)),
                    const SizedBox(width: 8),
                    const Text(
                      'Chantier',
                      style: TextStyle(color: Color(0xFF8A98A8), fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      _task.realEstateProperty?.name ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFFFF5C02)),
                    const SizedBox(width: 8),
                    const Text(
                      'Horaires',
                      style: TextStyle(color: Color(0xFF8A98A8), fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      _formatTaskDate(_task),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFFF5C02)),
                    const SizedBox(width: 8),
                    const Text(
                      'Superviseur',
                      style: TextStyle(color: Color(0xFF8A98A8), fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      _task.promoterName ?? _task.author ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.priority_high, color: Color(0xFFFF5C02)),
                    const SizedBox(width: 8),
                    const Text(
                      'Priorité',
                      style: TextStyle(color: Color(0xFF8A98A8), fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      _mapPriority(_task.priority),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFFFF5C02),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Documents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF8A98A8),
                  ),
                ),
                const SizedBox(height: 10),
                ..._task.documents
                    .map((doc) => _DocumentTile(doc: doc))
                    .toList(),
                const SizedBox(height: 30),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if ((isInProgress || isTodo))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed:
                          _loading
                              ? null
                              : () => _confirmAndChangeStatus(context),
                      icon:
                          _loading
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        isTodo ? 'Commencer' : 'Marquer comme terminé',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskActionConfirmBottomSheet extends StatelessWidget {
  final String action; // 'commencer' ou 'terminer'
  const TaskActionConfirmBottomSheet({Key? key, required this.action})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTerminer = action == 'terminer';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            isTerminer ? 'Terminer la tâche ?' : 'Commencer la tâche ?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 17, color: Color(0xFF8A98A8)),
              children: [
                const TextSpan(text: 'Souhaitez vous '),
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const TextSpan(text: ' la tâche'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE0E0E0)),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    isTerminer ? 'Oui, terminer' : 'Oui, commencer',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                    ),
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

class _DocumentTile extends StatelessWidget {
  final TaskDocument doc;
  const _DocumentTile({Key? key, required this.doc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = doc.libelle.isNotEmpty ? doc.libelle : doc.filePath;
    String ext = doc.filePath.split('.').last.toLowerCase();
    IconData icon;
    Color color;
    Color bgColor;
    if (ext == 'pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.redAccent;
      bgColor = const Color(0xFFFFEBEE);
    } else if (ext == 'doc' || ext == 'docx') {
      icon = Icons.description;
      color = Colors.blueAccent;
      bgColor = const Color(0xFFE3F0FF);
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
      bgColor = const Color(0xFFF5F7FA);
    }
    // Construction de l'URL du fichier (adapter selon ton backend)
    final String fileUrl = APIConstants.API_BASE_URL_IMG + doc.filePath;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d’ouvrir le document.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  // Taille du fichier (si disponible)
                  if (doc.filePath.contains('.pdf') ||
                      doc.filePath.contains('.doc'))
                    Text(
                      _getFakeFileSize(doc.filePath),
                      style: const TextStyle(
                        color: Color(0xFF8A98A8),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction factice pour la taille (à remplacer si l'API fournit la taille)
String _getFakeFileSize(String filePath) {
  if (filePath.contains('pdf')) return '298ko';
  if (filePath.contains('doc')) return '787ko';
  return '';
}

class TaskActionCompleteResult {
  final String comment;
  final List<File> photos;
  TaskActionCompleteResult({required this.comment, required this.photos});
}

class TaskActionCompleteBottomSheet extends StatefulWidget {
  final String taskTitle;
  final String action; // 'commencer' ou 'terminer'
  const TaskActionCompleteBottomSheet({
    Key? key,
    required this.taskTitle,
    required this.action,
  }) : super(key: key);

  @override
  State<TaskActionCompleteBottomSheet> createState() =>
      _TaskActionCompleteBottomSheetState();
}

class _TaskActionCompleteBottomSheetState
    extends State<TaskActionCompleteBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<File> _photos = [];
  bool _loading = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photos.add(File(picked.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final heure =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.action == 'terminer'
                      ? 'Tâche terminée'
                      : 'Tâche démarrée',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8A98A8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                  children: [
                    TextSpan(
                      text: widget.taskTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' terminée à '),
                    TextSpan(
                      text: heure,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ajouter un commentaire',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Saisir',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ajouter des photos',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Remplacement de DottedBorder par CustomPaint avec DottedBorderPainter
            CustomPaint(
              painter: DottedBorderPainter(
                radius: 12,
                color: const Color(0xFFFF5C02),
                dashPattern: const [6, 3],
                strokeWidth: 1.5,
              ),
              child: InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 90,
                  alignment: Alignment.center,
                  child:
                      _photos.isEmpty
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.camera_alt,
                                color: Color(0xFFFF5C02),
                                size: 32,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Photo',
                                style: TextStyle(
                                  color: Color(0xFF8A98A8),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                _photos
                                    .map(
                                      (file) => Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                file,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _photos.remove(file);
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Color(0xFF8A98A8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () {
                              Navigator.of(context).pop(
                                TaskActionCompleteResult(
                                  comment: _commentController.text,
                                  photos: _photos,
                                ),
                              );
                            },
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Ignorer',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1A365D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
