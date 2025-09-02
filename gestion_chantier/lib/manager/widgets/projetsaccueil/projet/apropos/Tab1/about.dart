// widgets/tabs/a_propos_tab.dart
// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:intl/intl.dart';

class AProposTab extends StatelessWidget {
  final RealEstateModel projet;
  final formatCurrency = NumberFormat("#,##0", "fr_FR");

  AProposTab({super.key, required this.projet});

  // Helper method to format dates
  String _formatProjectDates(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Dates à définir';
    }

    // Format dates as you prefer - here's a simple example
    final start = DateFormat('dd/MM/yyyy').format(startDate);
    final end = DateFormat('dd/MM/yyyy').format(endDate);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du projet
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  '${APIConstants.API_BASE_URL_IMG}${projet.plan}',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Titre du projet
          Text(
            projet.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HexColor('#1A365D'),
            ),
          ),
          SizedBox(height: 16),

          // Informations du projet
          Row(
            children: [
              Icon(Icons.location_on, color: HexColor("#FF5C02"), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  projet.address,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              SizedBox(width: 16),
              SvgPicture.asset(
                'assets/icons/calendar.svg', // Path to your SVG file
                width: 18,
                height: 18,
                color: HexColor("#FF5C02"),
              ),
              SizedBox(width: 8),
              Text(
                _formatProjectDates(projet.startDate, projet.endDate),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildProgressSection(
            progression: projet.averageProgress.round(),
            isMain: true,
          ),

          SizedBox(height: 24),

          // Description
          Text(
            'Description du projet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#1A365D'),
            ),
          ),
          SizedBox(height: 12),
          Text(
            projet.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 5),
          _buildProjectPrice(),
          _buildProjectInfo(),
          SizedBox(height: 20),
          _buildEquipementsSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProjectPrice() {
    return Padding(
      padding: EdgeInsets.all(7),
      child: Text(
        '${formatCurrency.format(projet.price)} FCFA',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: HexColor('#FF6B35'), // Couleur orangée pour le prix
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProjectInfo() {
    final infoItems = [
      {'label': 'Surface', 'value': '${projet.area.toString()} m2'},
      {'label': 'Emplacement', 'value': projet.address},
      {'label': 'Nombre de lots', 'value': projet.numberOfLots.toString()},
      {
        'label': 'Date d\'échéance',
        'value':
            projet.endDate != null
                ? DateFormat('dd/MM/yyyy').format(projet.endDate)
                : 'Non définie',
      },
    ];

    return Column(
      children:
          infoItems.asMap().entries.map((entry) {
            Map<String, String> item = entry.value;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: TextStyle(
                      fontSize: 15,
                      color: HexColor("#666666"),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: HexColor('#333333'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEquipementsSection() {
    // Filtrer les équipements disponibles
    final availableEquipments = _getAvailableEquipments();

    // Si aucun équipement n'est disponible, ne pas afficher la section
    if (availableEquipments.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Équipements communs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: HexColor('#333333'),
          ),
        ),
        SizedBox(height: 16),
        _buildEquipementsList(availableEquipments),
      ],
    );
  }

  // Méthode pour obtenir la liste des équipements disponibles
  List<Map<String, Object>> _getAvailableEquipments() {
    final List<Map<String, Object>> allEquipments = [
      if (projet.hasHall)
        {
          'icon': Icons.business,
          'title': 'Hall d\'entrée',
          'description': 'Espace d\'accueil de l\'immeuble',
        },
      if (projet.hasElevator)
        {
          'icon': Icons.elevator,
          'title': 'Ascenseur',
          'description': 'Accès facilité aux différents étages',
        },
      if (projet.hasParking)
        {
          'icon': Icons.local_parking,
          'title': 'Parking',
          'description': 'Espaces de stationnement sécurisés',
        },
      if (projet.hasSwimmingPool)
        {
          'icon': Icons.pool,
          'title': 'Piscine',
          'description': 'Espace de détente et de loisirs aquatiques',
        },
      if (projet.hasGym)
        {
          'icon': Icons.fitness_center,
          'title': 'Salle de sport',
          'description': 'Équipements de fitness et de musculation',
        },
      if (projet.hasPlayground)
        {
          'icon': Icons.games,
          'title': 'Aire de jeux',
          'description': 'Espace de jeux pour enfants',
        },
      if (projet.hasSecurityService)
        {
          'icon': Icons.security,
          'title': 'Service de sécurité',
          'description': 'Surveillance et sécurité 24h/24',
        },
      if (projet.hasGarden)
        {
          'icon': Icons.nature,
          'title': 'Jardin',
          'description': 'Espaces verts et jardins paysagers',
        },
      if (projet.hasSharedTerrace)
        {
          'icon': Icons.deck,
          'title': 'Terrasse partagée',
          'description': 'Espace extérieur commun avec vue',
        },
      if (projet.hasBicycleStorage)
        {
          'icon': Icons.pedal_bike,
          'title': 'Local à vélos',
          'description': 'Rangement sécurisé pour bicyclettes',
        },
      if (projet.hasLaundryRoom)
        {
          'icon': Icons.local_laundry_service,
          'title': 'Buanderie',
          'description': 'Espace de lavage et séchage commun',
        },
      if (projet.hasStorageRooms)
        {
          'icon': Icons.storage,
          'title': 'Locaux de stockage',
          'description': 'Espaces de rangement supplémentaires',
        },
      if (projet.hasWasteDisposalArea)
        {
          'icon': Icons.delete,
          'title': 'Zone de collecte des déchets',
          'description': 'Espace dédié à la gestion des déchets',
        },
    ];

    return allEquipments;
  }

  Widget _buildEquipementsList(List<Map<String, Object>> equipements) {
    return Column(
      children:
          equipements.asMap().entries.map((entry) {
            Map<String, Object> equipement = entry.value;

            return Container(
              padding: EdgeInsets.all(13),
              decoration: BoxDecoration(),
              child: Row(
                children: [
                  Icon(
                    equipement['icon'] as IconData,
                    color: HexColor('#333333'),
                    size: 24,
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipement['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HexColor('#333333'),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          equipement['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildProgressSection({
    required int progression,
    required bool isMain,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: TextStyle(
                fontSize: 14,
                color: HexColor('#64748B'),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$progression%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: HexColor("#333333"),
              ),
            ),
          ],
        ),
        SizedBox(height: isMain ? 8 : 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMain ? 4 : 3),
            color: Colors.grey[300]?.withOpacity(0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMain ? 4 : 3),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: HexColor('#E2E8F0'),
                    borderRadius: BorderRadius.circular(isMain ? 4 : 3),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 6,
                      width: constraints.maxWidth * (progression / 100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isMain ? 4 : 3),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF39C12), Color(0xFFFF5C02)],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
