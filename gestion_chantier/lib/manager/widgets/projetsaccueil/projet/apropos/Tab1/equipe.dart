// widgets/tabs/equipe_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_bloc.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_event.dart';
import 'package:gestion_chantier/manager/bloc/worker/worker_state.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/WorkerModel.dart';
import 'package:gestion_chantier/manager/services/worker_service.dart';

class EquipeTab extends StatelessWidget {
  final RealEstateModel projet;

  const EquipeTab({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              WorkerBloc(workerService: WorkerService())
                ..add(LoadWorkers(propertyId: projet.id)),

      child: Container(
        color: const Color(0xFFF8F9FA),
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: BlocBuilder<WorkerBloc, WorkerState>(
          builder: (context, state) {
            if (state is WorkerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WorkerError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WorkerBloc>().add(
                          RefreshWorkers(propertyId: projet.id),
                        );
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            } else if (state is WorkerLoaded) {
              if (state.workers.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun membre d\'équipe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Aucun worker n\'est assigné à ce projet',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WorkerBloc>().add(
                    RefreshWorkers(propertyId: projet.id),
                  );
                },
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: state.workers.length,
                  itemBuilder: (context, index) {
                    return _buildMemberCard(state.workers[index]);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMemberCard(WorkerModel worker) {
    // Définir les couleurs de fond selon le profil
    Color getBgColor(String profil) {
      switch (profil.toLowerCase()) {
        case 'chef de chantier':
          return const Color(0xFF87CEEB); // Bleu clair
        case 'maître d\'œuvre':
          return const Color(0xFFFFF8DC); // Jaune clair
        case 'ouvrier':
          return const Color(0xFFDDA0DD); // Violet clair
        default:
          return const Color(0xFFD3D3D3); // Gris clair
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Photo de profil avec cercle coloré
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getBgColor(worker.profil),
            ),
            child: ClipOval(
              child:
                  worker.photo != null
                      ? Image.network(
                        worker.photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback(
                            worker,
                            getBgColor(worker.profil),
                          );
                        },
                      )
                      : _buildAvatarFallback(worker, getBgColor(worker.profil)),
            ),
          ),

          const SizedBox(height: 8),
          // Nom complet
          Text(
            _getDisplayName(worker),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),
          // Profil/Rôle
          Text(
            _getDisplayProfil(worker),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),
          // Boutons de contact
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactButton(Icons.phone_outlined, () {
                // Action pour appeler - utiliser worker.telephone
                // Exemple: launch('tel:${worker.telephone}');
              }),
              const SizedBox(width: 16),
              _buildContactButton(Icons.email, () {
                // Action pour envoyer un email - utiliser worker.email
                // Exemple: launch('mailto:${worker.email}');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(WorkerModel worker, Color bgColor) {
    // Safe way to get initials - handle empty strings
    String getInitials() {
      String firstInitial = worker.prenom.isNotEmpty ? worker.prenom[0] : '';
      String lastInitial = worker.nom.isNotEmpty ? worker.nom[0] : '';

      // If both are empty, use a default
      if (firstInitial.isEmpty && lastInitial.isEmpty) {
        return 'U'; // Default to 'U' for User
      }

      return '$firstInitial$lastInitial'.toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(
        child: Text(
          getInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEDF2F7),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF4A5568)),
      ),
    );
  }

  // Helper method to get display name
  String _getDisplayName(WorkerModel worker) {
    String prenom = worker.prenom.trim();
    String nom = worker.nom.trim();

    if (prenom.isEmpty && nom.isEmpty) {
      return 'Utilisateur'; // Default name
    } else if (prenom.isEmpty) {
      return nom;
    } else if (nom.isEmpty) {
      return prenom;
    } else {
      return '$prenom $nom';
    }
  }

  // Helper method to get display profil
  String _getDisplayProfil(WorkerModel worker) {
    String profil = worker.profil.trim();
    return profil.isEmpty ? 'Non spécifié' : profil;
  }
}
