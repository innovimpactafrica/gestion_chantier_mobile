import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/models/WorkerModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/TaskStatusDistributionBloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/TaskStatusDistributionEvent.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/TaskStatusDistributionState.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_dashboard_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_dashboard_event.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_dashboard_state.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_monthly_summary_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_monthly_summary_event.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_monthly_summary_state.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_presence_history_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_presence_history_event.dart';
import 'package:gestion_chantier/ouvrier/bloc/worker/worker_presence_history_state.dart';
import 'package:gestion_chantier/ouvrier/models/MonthlySummaryModel.dart';
import 'package:gestion_chantier/ouvrier/models/TaskStatusDistribution.dart';
import 'package:gestion_chantier/ouvrier/repository/task_repository.dart';
import 'package:gestion_chantier/ouvrier/repository/worker_dashboard_repository.dart';
import 'package:gestion_chantier/ouvrier/repository/worker_repository.dart';
import 'package:gestion_chantier/ouvrier/services/task_service.dart' as ouv_task;
import 'package:gestion_chantier/ouvrier/services/worker_service.dart' as ouv_worker;
import 'package:gestion_chantier/ouvrier/utils/profile_utils.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:gestion_chantier/shared/utils/ContactUtils.dart';

class WorkerDetailPage extends StatelessWidget {
  final WorkerModel worker;
  const WorkerDetailPage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final workerService = ouv_worker.WorkerService();
    final taskService = ouv_task.TaskService();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WorkerDashboardBloc(
            repository: WorkerDashboardRepository(workerService: workerService),
          )..add(LoadWorkerDashboardEvent(worker.id)),
        ),
        BlocProvider(
          create: (_) => WorkerPresenceHistoryBloc(
            repository: WorkerRepository(workerService: workerService),
          ),
        ),
        BlocProvider(
          create: (_) => WorkerMonthlySummaryBloc(
            repository: WorkerRepository(workerService: workerService),
          )..add(LoadWorkerMonthlySummaryEvent(worker.id)),
        ),
        BlocProvider(
          create: (_) => TaskStatusDistributionBloc(
            repository: TaskRepository(taskService: taskService),
          )..add(LoadTaskStatusDistribution(worker.id)),
        ),
      ],
      child: _WorkerDetailContent(worker: worker),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WorkerDetailContent extends StatefulWidget {
  final WorkerModel worker;
  const _WorkerDetailContent({required this.worker});

  @override
  State<_WorkerDetailContent> createState() => _WorkerDetailContentState();
}

class _WorkerDetailContentState extends State<_WorkerDetailContent> {
  DateTime? _selectedDate;

  String _apiDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatHours(String raw) {
    try {
      if (raw.isEmpty) return '0h 00min';
      if (raw.contains(':')) {
        final parts = raw.split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        return '${h}h ${m.toString().padLeft(2, '0')}min';
      }
      final val = double.parse(raw);
      final h = val.floor();
      final m = ((val - h) * 60).round();
      return '${h}h ${m.toString().padLeft(2, '0')}min';
    } catch (_) {
      return '0h 00min';
    }
  }

  String _getInitials(WorkerModel w) {
    final p = w.prenom.isNotEmpty ? w.prenom[0] : '';
    final n = w.nom.isNotEmpty ? w.nom[0] : '';
    return (p + n).isEmpty ? 'U' : '$p$n'.toUpperCase();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: HexColor('#1A365D'),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      context.read<WorkerPresenceHistoryBloc>().add(
        LoadWorkerPresenceHistoryEvent(
          workerId: widget.worker.id,
          date: _apiDate(picked),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.worker;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildTopBar(),

            // ── Scrollable body ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte ouvrier
                    _buildWorkerCard(w),
                    const SizedBox(height: 16),

                    // Stats 2×2
                    _buildStatsGrid(),
                    const SizedBox(height: 16),

                    // Donut
                    _buildDonutCard(),
                    const SizedBox(height: 20),

                    // Présences header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Historique des présences',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: HexColor('#111827'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterButton(),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Total heures
                    _buildTotalHoursCard(),
                    const SizedBox(height: 10),

                    // Liste présences
                    _buildPresenceList(),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Text(
                  'Détails',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 17,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  // ── WORKER CARD ───────────────────────────────────────────────────────────

  Widget _buildWorkerCard(WorkerModel w) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFDDA0DD),
                backgroundImage: w.photo != null ? NetworkImage('${APIConstants.API_BASE_URL_IMG}${w.photo!}') : null,
                child: w.photo == null
                    ? Text(
                        _getInitials(w),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: w.present ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Nom / rôle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.prenom} ${w.nom}'.trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ProfileUtils.toFrench(w.profil),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              _outlinedCircleIcon(
                icon: Icons.phone_outlined,
                onTap: () => ContactUtils.callPhone(w.telephone),
              ),
              const SizedBox(width: 8),
              _outlinedCircleIcon(
                icon: Icons.mail_outline_rounded,
                onTap: () => ContactUtils.openWhatsApp(w.telephone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _outlinedCircleIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
          color: Colors.white,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
      ),
    );
  }

  // ── STATS GRID ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return BlocBuilder<WorkerDashboardBloc, WorkerDashboardState>(
      builder: (context, state) {
        if (state is WorkerDashboardLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is WorkerDashboardLoaded) {
          final d = state.dashboard;
          final items = [
            _StatItem('Jours présents',    '${d.daysPresent}',           Icons.access_time_rounded,        const Color(0xFFFF9500), const Color(0xFFFFF3DC)),
            _StatItem('Heures travaillées','${d.totalWorkedHours}',       Icons.hourglass_empty_rounded,    const Color(0xFF5B9BD5), const Color(0xFFEBF3FF)),
            _StatItem('Tâches terminées',  '${d.completedTasks}',        Icons.check_circle_outline_rounded,const Color(0xFF22C55E),const Color(0xFFEAF7EF)),
            _StatItem('Performance',       '${d.performancePercentage}%', Icons.trending_up_rounded,        const Color(0xFFEF4444), const Color(0xFFFFEBEB)),
          ];
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map(_statCard).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _statCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  // ── DONUT CARD ────────────────────────────────────────────────────────────

  Widget _buildDonutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des tâches (%)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<TaskStatusDistributionBloc, TaskStatusDistributionState>(
            builder: (context, state) {
              if (state is TaskStatusDistributionLoading) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is TaskStatusDistributionLoaded) {
                return _DonutRow(data: state.data);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // ── FILTER BUTTON ─────────────────────────────────────────────────────────

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              _selectedDate != null ? _displayDate(_selectedDate!) : 'Filtrer par date',
              style: TextStyle(
                fontSize: 12,
                color: _selectedDate != null ? HexColor('#1A365D') : const Color(0xFF6B7280),
                fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _selectedDate = null),
                child: const Icon(Icons.close, size: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── TOTAL HEURES CARD ─────────────────────────────────────────────────────

  Widget _buildTotalHoursCard() {
    return BlocBuilder<WorkerMonthlySummaryBloc, WorkerMonthlySummaryState>(
      builder: (context, state) {
        String total = '0h 00min';
        if (state is WorkerMonthlySummaryLoaded) {
          total = _formatHours(state.summary.totalWorkedTime);
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _cardDecor(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Heures travaillées',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── PRESENCE LIST ─────────────────────────────────────────────────────────

  Widget _buildPresenceList() {
    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: _cardDecor(),
        child: Column(
          children: const [
            Icon(Icons.calendar_month_outlined, size: 32, color: Color(0xFFD1D5DB)),
            SizedBox(height: 10),
            Text(
              'Choisissez une date pour\nvoir l\'historique de présence',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<WorkerPresenceHistoryBloc, WorkerPresenceHistoryState>(
      builder: (context, state) {
        if (state is WorkerPresenceHistoryLoading) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        Widget buildOrangeCard(Widget child) => Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: const Border(
              left: BorderSide(color: Color(0xFFFF5C02), width: 4),
            ),
          ),
          child: child,
        );

        if (state is WorkerPresenceHistoryError ||
            (state is WorkerPresenceHistoryLoaded && state.history.logs.isEmpty)) {
          return buildOrangeCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayDate(_selectedDate!),
                style: const TextStyle(
                  color: Color(0xFF1A365D),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aucune présence pour cette date',
                style: TextStyle(
                  color: Color(0xFF8A98A8),
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ));
        }

        if (state is WorkerPresenceHistoryLoaded) {
          final logs = state.history.logs;
          final total = state.history.totalWorkedTime;
          return buildOrangeCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayDate(_selectedDate!),
                style: const TextStyle(
                  color: Color(0xFF1A365D),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              ...logs.map((log) => _PresenceSessionCard(
                entree: log.formattedCheckIn,
                sortie: log.formattedCheckOut,
              )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: $total',
                    style: const TextStyle(
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ));
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── SHARED ────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );
}

// ── Value object ──────────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  const _StatItem(this.label, this.value, this.icon, this.iconColor, this.iconBg);
}

// ── Presence session card ─────────────────────────────────────────────────────

class _PresenceSessionCard extends StatelessWidget {
  final String? entree;
  final String? sortie;

  const _PresenceSessionCard({this.entree, this.sortie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/entrer.svg', width: 20, height: 20),
                    const SizedBox(width: 4),
                    const Text(
                      'Entrée:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entree ?? '--:--',
                      style: const TextStyle(color: Color(0xFF1A365D), fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/sortie.svg', width: 20, height: 20),
                    const SizedBox(width: 4),
                    const Text(
                      'Sortie:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sortie ?? '--:--',
                      style: const TextStyle(color: Color(0xFF1A365D), fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F9ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Présent',
              style: TextStyle(
                color: Color(0xFF3DD598),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donut row ─────────────────────────────────────────────────────────────────

class _DonutRow extends StatelessWidget {
  final List<TaskStatusDistribution> data;
  const _DonutRow({required this.data});

  Color _color(String s) {
    switch (s.toUpperCase()) {
      case 'TODO':        return const Color(0xFFBFC5D2);
      case 'IN_PROGRESS': return const Color(0xFFF2A93B);
      case 'DONE':        return const Color(0xFF60C56E);
      case 'DELAYED':
      case 'BLOCKED':     return const Color(0xFFEF4444);
      default:            return Colors.grey;
    }
  }

  String _label(String s) {
    switch (s.toUpperCase()) {
      case 'TODO':        return 'À Faire';
      case 'IN_PROGRESS': return 'En Cours';
      case 'DONE':        return 'Terminé';
      case 'DELAYED':
      case 'BLOCKED':     return 'En Retard';
      default:            return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nonEmpty = data.where((e) => e.percentage > 0).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Donut
        SizedBox(
          width: 110,
          height: 110,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 34,
              sectionsSpace: 2,
              sections: nonEmpty.isEmpty
                  ? [PieChartSectionData(value: 1, color: const Color(0xFFE5E7EB), showTitle: false, radius: 20)]
                  : nonEmpty.map((e) => PieChartSectionData(value: e.percentage, color: _color(e.status), showTitle: false, radius: 20)).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Légende
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: _color(e.status), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_label(e.status), style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                    ),
                    Text(
                      '${e.percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
