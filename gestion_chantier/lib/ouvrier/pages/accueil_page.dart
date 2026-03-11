import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/services/IncidentService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gestion_chantier/ouvrier/widgets/home/UserNameSection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_bloc.dart';
import 'package:gestion_chantier/ouvrier/repository/auth_repository.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_event.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_state.dart';
import '../../shared/utils/DateFormatUtils.dart';
import '../utils/profile_utils.dart';
import '../utils/ToastUtils.dart';
import '../widgets/home/stats_grid.dart';
import '../bloc/worker/worker_tasks_bloc.dart';
import '../bloc/worker/worker_tasks_event.dart';
import '../bloc/worker/worker_tasks_state.dart';
import '../repository/task_repository.dart';
import '../services/task_service.dart';
import '../models/TaskModel.dart';
import '../widgets/task/TaskStatusDonut.dart';
import 'taches_page.dart';

class AccueilOuvrierPage extends StatefulWidget {
  final VoidCallback onVoirPlus;

  const AccueilOuvrierPage({Key? key, required this.onVoirPlus})
    : super(key: key);

  @override
  State<AccueilOuvrierPage> createState() => _AccueilOuvrierPageState();
}

class _AccueilOuvrierPageState extends State<AccueilOuvrierPage> {
  int? _propertyId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: BlocProvider<UserNameSectionBloc>(
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
                ),
                const SizedBox(height: 32),
                _TodayTasksSection(
                  onVoirPlus: widget.onVoirPlus,
                  onPropertyIdFound: (id) {
                    if (_propertyId != id) {
                      setState(() => _propertyId = id);
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _SignalementModal(propertyId: _propertyId),
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C02),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5C02).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.flag_outlined, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
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
              state is UserNameLoaded
                  ? ProfileUtils.toFrench(state.user.profil)
                  : 'Ouvrier';

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
                Transform.translate(
                  offset: const Offset(0, -8),
                  child: SvgPicture.asset(
                    'assets/icons/Bell_pin.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 16),
                /* Stack(
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
                ),*/
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
            return const SizedBox(height: 105);
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
            height: 105,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.only(left: 16, top: 24),
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
                    fontFamily: 'Inter',
                    color: Color(0xFF1A365D),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  "Voici votre activité pour aujourd'hui",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 24 / 14,
                    letterSpacing: 0,
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
  final ValueChanged<int?>? onPropertyIdFound;

  const _TodayTasksSection({required this.onVoirPlus, this.onPropertyIdFound});

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
                    // Extract propertyId from the first task that has one
                    final foundId = taskState.tasks
                        .map((t) => t.realEstateProperty?.id)
                        .firstWhere((id) => id != null, orElse: () => null);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onPropertyIdFound?.call(foundId);
                    });
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tasks.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tâches aujourd'hui",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 19.61,
                                    height: 1.0,
                                    letterSpacing: 0,
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
                                      onTap: () async {
                                        final result =
                                            await showModalBottomSheet<bool>(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            24,
                                                          ),
                                                        ),
                                                  ),
                                              builder:
                                                  (_) => TaskDetailBottomSheet(
                                                    task: task,
                                                  ),
                                            );

                                        // result == true si la tâche a été changée
                                        if (result == true) {
                                          final workerId =
                                              task.executors.isNotEmpty
                                                  ? task.executors[0].id
                                                  : null;
                                          if (workerId != null) {
                                            BlocProvider.of<WorkerTasksBloc>(
                                              context,
                                            ).add(
                                              LoadWorkerTasksEvent(workerId),
                                            );
                                          }
                                        }
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
                                          final result =
                                              await showModalBottomSheet<bool>(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  24,
                                                                ),
                                                          ),
                                                    ),
                                                builder:
                                                    (_) =>
                                                        TaskDetailBottomSheet(
                                                          task: task,
                                                        ),
                                              );

                                          // result == true si la tâche a été changée
                                          if (result == true) {
                                            print(
                                              "Tâche modifiée_____acheuil !",
                                            );
                                          }

                                          /*
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
                                          */
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
  return DateFormatUtils.formatTaskPeriodWithTime(task.startDate, task.endDate);
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
              SvgPicture.asset(
                'assets/icons/pending.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(HexColor('#6C757D'), BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF6C757D),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.0,
                  letterSpacing: 0,
                ),
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

// ─── Modal Signalement ───────────────────────────────────────────────────────

class _SignalementModal extends StatefulWidget {
  final int? propertyId;

  const _SignalementModal({this.propertyId});

  @override
  State<_SignalementModal> createState() => _SignalementModalState();
}

class _SignalementModalState extends State<_SignalementModal> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _photos = [];
  bool _sending = false;

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _viewPhoto(File file) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(file, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _photos.add(File(picked.path)));
    }
  }

  Future<void> _envoyerSignalement() async {
    final titre = _titreController.text.trim();
    final description = _descriptionController.text.trim();
    if (titre.isEmpty) {
      ToastUtils.show('Veuillez saisir un titre.');
      return;
    }
    if (description.isEmpty) {
      ToastUtils.show('Veuillez saisir une description.');
      return;
    }
    setState(() => _sending = true);
    try {
      await IncidentService().addIncident(
        title: titre,
        description: description,
        propertyId: widget.propertyId,
        pictures: _photos,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ToastUtils.show('Signalement envoyé avec succès.');
      }
    } catch (e) {
      if (mounted) ToastUtils.show('Erreur: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    int maxLines = 1,
    int minLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE1E9), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            minLines: minLines,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFBFC5D2),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE1E9),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C02).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFFFF5C02),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faire un signalement',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Informez votre responsable d'un problème",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF8A98A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildField(
            label: 'Titre',
            controller: _titreController,
            hint: "Ex: Problème d'accès au chantier…",
          ),
          const SizedBox(height: 18),
          _buildField(
            label: 'Description',
            controller: _descriptionController,
            hint: 'Décrivez le problème rencontré…',
            maxLines: 5,
            minLines: 4,
          ),
          const SizedBox(height: 18),
          // ── Section photos ──
          const Text(
            'Photos',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (_photos.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == _photos.length) {
                    return GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDDE1E9)),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined,
                            color: Color(0xFFFF5C02), size: 28),
                      ),
                    );
                  }
                  final file = _photos[i];
                  return GestureDetector(
                    onTap: () => _viewPhoto(file),
                    child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(file,
                            width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _photos.remove(file)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  );
                },
              ),
            )
          else
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDE1E9), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Color(0xFFFF5C02), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter des photos',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF8A98A8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _sending ? null : _envoyerSignalement,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C02),
                disabledBackgroundColor: const Color(0xFFFF5C02).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Envoyer signalement',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
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
