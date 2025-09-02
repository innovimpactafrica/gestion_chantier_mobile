import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/username/user_name_section_bloc.dart';
import '../bloc/username/user_name_section_event.dart';
import '../bloc/username/user_name_section_state.dart';
import '../repository/auth_repository.dart';
import '../bloc/worker/worker_monthly_summary_bloc.dart';
import '../bloc/worker/worker_monthly_summary_event.dart';
import '../bloc/worker/worker_monthly_summary_state.dart';
import '../repository/worker_repository.dart';
import '../services/worker_service.dart';
import '../models/MonthlySummaryModel.dart';
import '../bloc/worker/worker_check_bloc.dart';
import '../bloc/worker/worker_check_event.dart';
import '../bloc/worker/worker_check_state.dart';
import '../bloc/worker/worker_presence_history_bloc.dart';
import '../bloc/worker/worker_presence_history_event.dart';
import '../bloc/worker/worker_presence_history_state.dart';
import '../services/location_service.dart';
import 'qr_scanner_page.dart';

class PointagePage extends StatefulWidget {
  const PointagePage({Key? key}) : super(key: key);

  @override
  State<PointagePage> createState() => _PointagePageState();
}

class _PointagePageState extends State<PointagePage> {
  int _selectedTab = 0;

  void _goToHistorique() {
    setState(() {
      _selectedTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PointageHeaderTabs(
            selected: _selectedTab,
            onChanged: (i) => setState(() => _selectedTab = i),
          ),
          Expanded(
            child:
                _selectedTab == 0
                    ? _PointageDuJourCard(onVoirPlus: _goToHistorique)
                    : const _HistoriqueTab(),
          ),
        ],
      ),
    );
  }
}

class _PointageHeaderTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _PointageHeaderTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#1A365D'),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
            child: Text(
              'Pointage',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color:
                                selected == 0
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pointage du jour',
                            style: TextStyle(
                              color:
                                  selected == 0
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          color:
                              selected == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color:
                                selected == 1
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Historiques',
                            style: TextStyle(
                              color:
                                  selected == 1
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          color:
                              selected == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
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

// ignore: unused_element
class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? HexColor('#1A365D') : const Color(0xFFBFC5D2),
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? HexColor('#1A365D') : const Color(0xFFBFC5D2),
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointageDuJourCard extends StatelessWidget {
  final VoidCallback onVoirPlus;
  const _PointageDuJourCard({Key? key, required this.onVoirPlus})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, userState) {
          if (userState is UserNameLoaded) {
            final workerId = userState.user.id;
            return BlocProvider<WorkerCheckBloc>(
              create:
                  (_) => WorkerCheckBloc(
                    repository: WorkerRepository(
                      workerService: WorkerService(),
                    ),
                  ),
              child: _PointageDuJourCardContent(
                workerId: workerId,
                onVoirPlus: onVoirPlus,
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _PointageDuJourCardContent extends StatefulWidget {
  final int workerId;
  final VoidCallback onVoirPlus;
  const _PointageDuJourCardContent({
    required this.workerId,
    required this.onVoirPlus,
  });
  @override
  State<_PointageDuJourCardContent> createState() =>
      _PointageDuJourCardContentState();
}

class _PointageDuJourCardContentState
    extends State<_PointageDuJourCardContent> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkerCheckBloc>(
          create:
              (_) => WorkerCheckBloc(
                repository: WorkerRepository(workerService: WorkerService()),
              ),
        ),
        BlocProvider<WorkerPresenceHistoryBloc>(
          create:
              (_) => WorkerPresenceHistoryBloc(
                repository: WorkerRepository(workerService: WorkerService()),
              )..add(LoadWorkerPresenceHistoryEvent(widget.workerId)),
        ),
      ],
      child: BlocListener<WorkerCheckBloc, WorkerCheckState>(
        listener: (context, state) {
          if (state is WorkerCheckSuccess) {
            // Rafraîchir la liste après un check
            BlocProvider.of<WorkerPresenceHistoryBloc>(
              context,
            ).add(LoadWorkerPresenceHistoryEvent(widget.workerId));
          }
        },
        child: BlocBuilder<
          WorkerPresenceHistoryBloc,
          WorkerPresenceHistoryState
        >(
          builder: (context, state) {
            if (state is WorkerPresenceHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WorkerPresenceHistoryLoaded) {
              final sessions = state.history.logs;
              final total = state.history.totalWorkedTime;
              return SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 24),
                child: Column(
                  children: [
                    Text(
                      'Pointage du jour',
                      style: TextStyle(
                        color: HexColor('#1A365D'),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.92,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.qr_code_2,
                                color: HexColor('#1A365D'),
                                size: 56,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Pointé aujourd'hui à ${sessions.isNotEmpty ? sessions.first.formattedCheckIn : '--:--'}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF8A98A8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            BlocBuilder<WorkerCheckBloc, WorkerCheckState>(
                              builder: (context, checkState) {
                                return SizedBox(
                                  width: 260,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF5C02),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(28),
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed:
                                        checkState is WorkerCheckLoading
                                            ? null
                                            : () {
                                              BlocProvider.of<WorkerCheckBloc>(
                                                context,
                                              ).add(
                                                DoWorkerCheckEvent(
                                                  widget.workerId,
                                                ),
                                              );
                                            },
                                    icon:
                                        checkState is WorkerCheckLoading
                                            ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.qr_code_2,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                    label: const Text(
                                      'Scanner QR Code',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Section Historiques de présence
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Historiques de présence',
                                style: TextStyle(
                                  color: Color(0xFF1A365D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onVoirPlus,
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFFFF5C02),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Voir plus',
                                  style: TextStyle(
                                    color: Color(0xFFFF5C02),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: const Border(
                                left: BorderSide(
                                  color: Color(0xFFFF5C02),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTodayDateString(),
                                    style: const TextStyle(
                                      color: Color(0xFF1A365D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (sessions.isEmpty)
                                    const Text(
                                      'Pas encore de pointage aujourd’hui',
                                      style: TextStyle(
                                        color: Color(0xFF8A98A8),
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  else
                                    for (final session in sessions)
                                      _SessionCard(
                                        entree: session.formattedCheckIn,
                                        sortie: session.formattedCheckOut,
                                      ),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is WorkerPresenceHistoryError) {
              // Affichage "pas encore de pointage" comme pour une liste vide
              return SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 24),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.92,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.qr_code_2,
                                color: HexColor('#1A365D'),
                                size: 56,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Pointé aujourd'hui à --:--",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF8A98A8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 260,
                              height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF5C02),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(28),
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => QRScannerPage(
                                            workerId: widget.workerId,
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.qr_code_2,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'Scanner QR Code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Expanded(
                            child: Text(
                              'Historiques de présence',
                              style: TextStyle(
                                color: HexColor('#1A365D'),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFFF5C02), width: 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTodayDateString(),
                            style: const TextStyle(
                              color: Color(0xFF1A365D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Pas encore de pointage aujourd’hui',
                            style: TextStyle(
                              color: Color(0xFF8A98A8),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    final months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    final weekDays = ['Dim.', 'Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.'];
    return '${weekDays[now.weekday % 7]} ${now.day.toString().padLeft(2, '0')} ${months[now.month]} ${now.year}';
  }
}

class _SessionCard extends StatelessWidget {
  final String? entree;
  final String? sortie;
  const _SessionCard({this.entree, this.sortie});
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
                    SvgPicture.asset(
                      'assets/icons/entrer.svg',
                      width: 20,
                      height: 20,
                    ),
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
                      style: const TextStyle(
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/sortie.svg',
                      width: 20,
                      height: 20,
                    ),
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
                      style: const TextStyle(
                        color: Color(0xFF1A365D),
                        fontSize: 15,
                      ),
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

// Nouveau widget dynamique pour l'historique
class _HistoriqueTab extends StatelessWidget {
  const _HistoriqueTab();
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, userState) {
          if (userState is UserNameLoaded) {
            final workerId = userState.user.id;
            return BlocProvider<WorkerMonthlySummaryBloc>(
              create:
                  (_) => WorkerMonthlySummaryBloc(
                    repository: WorkerRepository(
                      workerService: WorkerService(),
                    ),
                  )..add(LoadWorkerMonthlySummaryEvent(workerId)),
              child: BlocBuilder<
                WorkerMonthlySummaryBloc,
                WorkerMonthlySummaryState
              >(
                builder: (context, state) {
                  if (state is WorkerMonthlySummaryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WorkerMonthlySummaryLoaded) {
                    final summary = state.summary;
                    return _HistoriqueList(summary: summary);
                  } else if (state is WorkerMonthlySummaryError) {
                    return Center(
                      child: Text(
                        state.message,
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
    );
  }
}

class _HistoriqueList extends StatelessWidget {
  final MonthlySummaryModel summary;
  const _HistoriqueList({required this.summary});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getCurrentMonthString(),
                  style: const TextStyle(
                    color: Color(0xFF1A365D),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  summary.totalWorkedTime,
                  style: const TextStyle(
                    color: Color(0xFF8A98A8),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          for (final day in summary.dailySummaries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    // Parse la date du format "16-07-2025" ou "2025-07-16" selon l'API
                    DateTime? selectedDate;
                    try {
                      final parts = day.day.split('-');
                      if (parts.length == 3) {
                        // API: "16-07-2025" (jour-mois-année)
                        selectedDate = DateTime.parse(
                          '${parts[2]}-${parts[1]}-${parts[0]}',
                        );
                      }
                    } catch (_) {}
                    if (selectedDate == null) return;
                    final workerId =
                        (BlocProvider.of<UserNameSectionBloc>(context).state
                                as UserNameLoaded)
                            .user
                            .id;
                    // Charge les sessions de la journée
                    final repo = WorkerRepository(
                      workerService: WorkerService(),
                    );
                    final history = await repo.getPresenceHistory(workerId);
                    final sessions =
                        history.logs.where((log) {
                          // On suppose que checkInTime contient [h, m, s, ...] et la date est celle du jour sélectionné
                          // Il faut une info de date dans PresenceLog, sinon on ne peut pas filtrer précisément
                          // Ici, on suppose que tous les logs du jour sont renvoyés (sinon il faut adapter le modèle)
                          return true; // à adapter si besoin
                        }).toList();
                    final total = day.hoursWorked;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => HistoriqueDetailPage(
                              date: day.day,
                              sessions: sessions,
                              total: total,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatLongDate(day.day),
                                style: const TextStyle(
                                  color: Color(0xFF1A365D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${day.hoursWorked}',
                                style: const TextStyle(
                                  color: Color(0xFF8A98A8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFBFC5D2),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCurrentMonthString() {
    final now = DateTime.now();
    const months = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[now.month]} ${now.year}';
  }
}

// Page de détail historique
class HistoriqueDetailPage extends StatelessWidget {
  final String date;
  final List sessions;
  final String total;
  const HistoriqueDetailPage({
    required this.date,
    required this.sessions,
    required this.total,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _formatLongDate(date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final session in sessions)
              _SessionCard(
                entree: session.formattedCheckIn,
                sortie: session.formattedCheckOut,
              ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Total: $total',
                style: const TextStyle(
                  color: Color(0xFF1A365D),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatage date longue
String _formatLongDate(String input) {
  // Attend "16-07-2025" ou "2025-07-16"
  DateTime? dt;
  final parts = input.split('-');
  if (parts.length == 3) {
    // "16-07-2025"
    dt = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
  }
  if (dt == null) return input;
  const jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  const mois = [
    '',
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];
  final jour = jours[dt.weekday - 1];
  final moisStr = mois[dt.month];
  return '$jour ${dt.day} $moisStr ${dt.year}';
}

// Nouvelle page HistoriqueOuvrierPage
class HistoriqueOuvrierPage extends StatelessWidget {
  const HistoriqueOuvrierPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Réutilise le même contenu que _HistoriquePlaceholder
    final historiques = [
      {
        'mois': 'Juillet 2025',
        'total': '87h 26',
        'jours': [
          {'date': 'Mer. 16 juil. 2025', 'total': '11h 20min'},
          {'date': 'Mar. 15 juil. 2025', 'total': '8h 40min'},
          {'date': 'Lun. 14 juil. 2025', 'total': '8h 30min'},
          {'date': 'Ven. 11 juil. 2025', 'total': '8h 45min'},
          {'date': 'Jeu. 10 juil. 2025', 'total': '8h 00min'},
          {'date': 'Mer. 09 juil. 2025', 'total': '09h 04min'},
        ],
      },
      {
        'mois': 'Juin 2025',
        'total': '151h 36',
        'jours': [
          {'date': 'Lun. 30 juin 2025', 'total': '8h 58min'},
          {'date': 'Ven. 27 juin 2025', 'total': '8h 30min'},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A365D)),
        title: const Text(
          'Historiques de présence',
          style: TextStyle(
            color: Color(0xFF1A365D),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final mois in historiques) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mois['mois'] as String,
                      style: const TextStyle(
                        color: Color(0xFF1A365D),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      mois['total'] as String,
                      style: const TextStyle(
                        color: Color(0xFF8A98A8),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              for (final jour in (mois['jours'] as List))
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jour['date'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF1A365D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total: ${jour['total']}',
                                    style: const TextStyle(
                                      color: Color(0xFF8A98A8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFBFC5D2),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher la position et permettre le test
class LocationTestWidget extends StatefulWidget {
  final int workerId;

  const LocationTestWidget({Key? key, required this.workerId})
    : super(key: key);

  @override
  State<LocationTestWidget> createState() => _LocationTestWidgetState();
}

class _LocationTestWidgetState extends State<LocationTestWidget> {
  final LocationService _locationService = LocationService();
  String _locationStatus = 'Non testé';
  String _latitude = '';
  String _longitude = '';
  bool _isLoading = false;

  Future<void> _testLocation() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Récupération de la position...';
    });

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _locationStatus = 'Position récupérée avec succès';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _testPointage() async {
    if (_latitude.isEmpty || _longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d\'abord récupérer votre position'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _locationStatus = 'Test du pointage...';
    });

    try {
      // Simuler un QR code pour le test
      const testQrCode =
          'MYaysI63OH2gF%2BzpZUJ%2BbzYnvxoxxr%2FL3Ac%2BJmw0PG8%3D';

      BlocProvider.of<WorkerCheckBloc>(
        context,
      ).add(DoWorkerCheckEvent(widget.workerId, qrCodeText: testQrCode));

      setState(() {
        _locationStatus = 'Pointage testé avec succès';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Erreur lors du pointage: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test de Géolocalisation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Statut: $_locationStatus',
            style: TextStyle(
              fontSize: 14,
              color:
                  _locationStatus.contains('Erreur')
                      ? Colors.red
                      : Colors.green,
            ),
          ),
          if (_latitude.isNotEmpty && _longitude.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Latitude: $_latitude'),
            Text('Longitude: $_longitude'),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A365D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Récupérer Position'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testPointage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C02),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tester Pointage'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
