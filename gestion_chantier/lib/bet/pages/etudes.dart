import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/utils/constant.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_bloc.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_event.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_state.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';
import 'etude_detail.dart';

class BetEtudesPage extends StatefulWidget {
  final int currentUserId;

  const BetEtudesPage({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  State<BetEtudesPage> createState() => _BetEtudesPageState();
}

class _BetEtudesPageState extends State<BetEtudesPage> {
  String selectedFilter = 'Tous';
  bool _isRefreshing = false;

  final List<String> filters = [
    'Tous',
    'En attente',
    'En cours',
    'Validées',
    'Rejetées',
  ];

  @override
  void initState() {
    super.initState();
    // Charger les études au démarrage
    context.read<BetStudiesBloc>().add(
      LoadBetStudies(betId: widget.currentUserId),
    );
  }

  List<BetStudyModel> _getFilteredStudies(List<BetStudyModel> studies) {
    if (selectedFilter == 'Tous') return studies;

    return studies.where((study) {
      switch (selectedFilter) {
        case 'En attente':
          return study.status == 'PENDING';
        case 'En cours':
          return study.status == 'IN_PROGRESS';
        case 'Validées':
          return study.status == 'VALIDATED';
        case 'Rejetées':
          return study.status == 'REJECTED';
        default:
          return true;
      }
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey.shade700; // Texte gris foncé
      case 'IN_PROGRESS':
        return Colors.grey.shade700; // Texte gris foncé
      case 'VALIDATED':
        return Colors.white; // Texte blanc
      case 'REJECTED':
        return Colors.white; // Texte blanc
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.grey.shade200; // Badge gris clair
      case 'IN_PROGRESS':
        return Colors.yellow.shade300; // Badge jaune
      case 'VALIDATED':
        return Colors.green.shade600; // Badge vert
      case 'REJECTED':
        return Colors.red.shade600; // Badge rouge
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            height: 120,
            decoration: BoxDecoration(color: HexColor('#1A365D')),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Demandes d\'études',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filtres
          Container(
            height: 60,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? HexColor('#FF5C02')
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicateur de rafraîchissement
          if (_isRefreshing)
            Container(
              height: 40,
              color: HexColor('#FFF3E0'),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HexColor('#FF5C02'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mise à jour...',
                      style: TextStyle(
                        color: HexColor('#FF5C02'),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Liste des études
          Expanded(
            child: BlocBuilder<BetStudiesBloc, BetStudiesState>(
              builder: (context, state) {
                if (state is BetStudiesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BetStudiesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${state.message}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<BetStudiesBloc>().add(
                                RefreshBetStudies(betId: widget.currentUserId),
                              ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                } else if (state is BetStudiesLoaded ||
                    state is BetStudiesLoadingMore) {
                  final studies =
                      state is BetStudiesLoaded
                          ? state.studies
                          : (state as BetStudiesLoadingMore).studies;
                  final filteredStudies = _getFilteredStudies(studies);

                  if (filteredStudies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune étude avec le statut "$selectedFilter"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStudies.length,
                    itemBuilder: (context, index) {
                      final study = filteredStudies[index];
                      return _buildStudyCard(study);
                    },
                  );
                }

                return const Center(child: Text('État inattendu'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyCard(BetStudyModel study) {
    return GestureDetector(
      onTap: () async {
        try {
          final studyMap = _convertToMap(study);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BetEtudeDetailPage(
                    study: studyMap,
                  currentUserId: widget.currentUserId,
                ),
          ),
        );

        // Si le statut a été modifié, rafraîchir la liste
        if (result == true) {
            if (mounted) {
          setState(() {
            _isRefreshing = true;
          });

          context.read<BetStudiesBloc>().add(
            LoadBetStudies(betId: widget.currentUserId),
          );

          // Arrêter l'indicateur de rafraîchissement après un délai
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _isRefreshing = false;
              });
            }
          });
            }
          }
        } catch (e) {
          print('❌ Erreur lors de la navigation vers les détails: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      study.propertyImg.isNotEmpty
                          ? Image.network(
                            '${APIConstants.API_BASE_URL_IMG}${study.propertyImg}',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                '❌ Erreur chargement image: ${study.propertyImg}',
                              );
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.business,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne avec titre et badge de statut
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            study.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBackgroundColor(study.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            study.statusDisplayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(study.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créé le ${study.formattedCreatedDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _convertToMap(BetStudyModel study) {
    return {
      'id': study.id,
      'title': study.title,
      'description': study.description,
      'status': study.statusDisplayName,
      'createdDate': study.formattedCreatedDate,
      'propertyId': study.propertyId,
      'propertyName': study.propertyName,
      'propertyImg': study.propertyImg,
      'moaId': study.moaId,
      'moaName': study.moaName,
      'betId': study.betId,
      'betName': study.betName,
      'reports': study.reports.map((report) => report.toJson()).toList(),
      'image':
          study.propertyImg.isNotEmpty
              ? '${APIConstants.API_BASE_URL_IMG}${study.propertyImg}'
              : 'assets/images/img.png',
    };
  }
}
