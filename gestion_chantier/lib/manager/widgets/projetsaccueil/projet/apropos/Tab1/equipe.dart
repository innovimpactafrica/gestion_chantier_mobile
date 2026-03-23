// widgets/tabs/equipe_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_bloc.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_event.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_state.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/WorkerModel.dart';
import 'package:gestion_chantier/manager/services/worker_service.dart';
import 'package:gestion_chantier/manager/widgets/rstate/CreateWorkerBottomSheet.dart';
import 'package:gestion_chantier/manager/pages/workers/worker_detail_page.dart';
import 'package:gestion_chantier/l10n/app_localizations.dart';
import 'package:gestion_chantier/ouvrier/utils/profile_utils.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:gestion_chantier/shared/utils/ContactUtils.dart';

class EquipeTab extends StatelessWidget {
  final RealEstateModel projet;

  const EquipeTab({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkerBloc(
        workerService: WorkerService(),
      )..add(LoadWorkers(propertyId: projet.id)),

      /// ⬇️ Builder OBLIGATOIRE pour avoir le bon context
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),

            /// ================= FAB =================
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(blocContext).primaryColor,
              child: const Icon(Icons.person_add, color: Colors.white),
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: blocContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CreateWorkerBottomSheet(
                    projetId: projet.id,
                  ),
                );

                /// 🔄 Refresh après création
                if (result == true) {
                  blocContext.read<WorkerBloc>().add(
                    RefreshWorkers(propertyId: projet.id),
                  );
                }
              },
            ),

            /// ================= BODY =================
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<WorkerBloc, WorkerState>(
                builder: (context, state) {
                  if (state is WorkerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is WorkerError) {
                    return _buildError(blocContext, state.message);
                  }

                  if (state is WorkerLoaded) {
                    if (state.workers.isEmpty) {
                      return _buildEmpty(context);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        blocContext.read<WorkerBloc>().add(
                          RefreshWorkers(propertyId: projet.id),
                        );
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: state.workers.length,
                        itemBuilder: (_, index) => GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkerDetailPage(
                                worker: state.workers[index],
                              ),
                            ),
                          ),
                          child: _buildMemberCard(state.workers[index]),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= UI STATES =================

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 12),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WorkerBloc>().add(
                RefreshWorkers(propertyId: projet.id),
              );
            },
            child: Text(AppLocalizations.of(context)!.teamRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            l10n.teamEmpty,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            l10n.teamEmptySubtitle,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= MEMBER CARD =================

  Widget _buildMemberCard(WorkerModel worker) {
    Color getBgColor(String profil) {
      switch (profil.toLowerCase()) {
        case 'chef de chantier':
          return const Color(0xFF87CEEB);
        case 'maître d\'œuvre':
          return const Color(0xFFFFF8DC);
        case 'ouvrier':
          return const Color(0xFFDDA0DD);
        default:
          return const Color(0xFFD3D3D3);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: getBgColor(worker.profil),
                backgroundImage:
                worker.photo != null ? NetworkImage('${APIConstants.API_BASE_URL_IMG}${worker.photo!}') : null,
                child: worker.photo == null
                    ? Text(
                  _getInitials(worker),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: worker.present ? Colors.green : Colors.red,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDisplayName(worker),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            ProfileUtils.toFrench(worker.profil),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _contactButton(Icons.phone, () {
                ContactUtils.callPhone(worker.telephone);
              }),
              const SizedBox(width: 16),
              _contactButton(Icons.message, () {
                ContactUtils.openWhatsApp(worker.telephone);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _contactButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFFEDF2F7),
        child: Icon(icon, size: 16, color: const Color(0xFF4A5568)),
      ),
    );
  }

  String _getInitials(WorkerModel worker) {
    final p = worker.prenom.isNotEmpty ? worker.prenom[0] : '';
    final n = worker.nom.isNotEmpty ? worker.nom[0] : '';
    return (p + n).isEmpty ? 'U' : '$p$n'.toUpperCase();
  }

  String _getDisplayName(WorkerModel worker) {
    final name = '${worker.prenom} ${worker.nom}'.trim();
    return name.isEmpty ? 'Utilisateur' : name;
  }
}
