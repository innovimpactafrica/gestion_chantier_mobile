// widgets/tabs/a_propos_tab.dart
// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:gestion_chantier/shared/widgets/network_image_or_svg.dart';
import 'package:gestion_chantier/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AProposTab extends StatelessWidget {
  final RealEstateModel projet;
  final formatCurrency = NumberFormat("#,##0", "fr_FR");

  AProposTab({super.key, required this.projet});

  // Helper method to format dates
  String _formatProjectDates(DateTime? startDate, DateTime? endDate, BuildContext context) {
    if (startDate == null || endDate == null) {
      return AppLocalizations.of(context)!.aboutDatesUndefined;
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: NetworkImageOrSvg(
                url: '${APIConstants.API_BASE_URL_IMG}${projet.plan}',
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
                _formatProjectDates(projet.startDate, projet.endDate, context),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 20),

          _buildProgressSection(
            progression: projet.averageProgress!.round(),
            isMain: true,
            context: context,
          ),

          SizedBox(height: 24),

          // Description
          Text(
            AppLocalizations.of(context)!.aboutDescription,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#1A365D'),
            ),
          ),
          SizedBox(height: 12),
          Text(
            projet.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 5),
          _buildProjectPrice(),
          _buildProjectInfo(context),
          SizedBox(height: 20),
          _buildEquipementsSection(context),
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

  Widget _buildProjectInfo(BuildContext context) {
    final infoItems = [
      {'label': AppLocalizations.of(context)!.aboutSurface, 'value': '${projet.area.toString()} m2'},
      {'label': AppLocalizations.of(context)!.aboutLocation, 'value': projet.address},
      {'label': AppLocalizations.of(context)!.aboutLots, 'value': projet.numberOfLots.toString()},
      {
        'label': AppLocalizations.of(context)!.aboutDeadline,
        'value':
            projet.endDate != null
                ? DateFormat('dd/MM/yyyy').format(projet.endDate!)
                : AppLocalizations.of(context)!.aboutDeadlineUndefined,
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
                  Flexible(
                    child: Text(
                      item['value']!,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: HexColor('#333333'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEquipementsSection(BuildContext context) {
    final availableEquipments = _getAvailableEquipments(context);

    // Si aucun équipement n'est disponible, ne pas afficher la section
    if (availableEquipments.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.aboutEquipments,
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
  List<Map<String, Object>> _getAvailableEquipments(BuildContext context) {
    final List<Map<String, Object>> allEquipments = [
      if (projet.hasHall)
        {
          'icon': Icons.business,
          'title': AppLocalizations.of(context)!.aboutHall,
          'description': AppLocalizations.of(context)!.aboutHallDesc,
        },
      if (projet.hasElevator)
        {
          'icon': Icons.elevator,
          'title': AppLocalizations.of(context)!.aboutElevator,
          'description': AppLocalizations.of(context)!.aboutElevatorDesc,
        },
      if (projet.hasParking)
        {
          'icon': Icons.local_parking,
          'title': AppLocalizations.of(context)!.aboutParking,
          'description': AppLocalizations.of(context)!.aboutParkingDesc,
        },
      if (projet.hasSwimmingPool)
        {
          'icon': Icons.pool,
          'title': AppLocalizations.of(context)!.aboutPool,
          'description': AppLocalizations.of(context)!.aboutPoolDesc,
        },
      if (projet.hasGym)
        {
          'icon': Icons.fitness_center,
          'title': AppLocalizations.of(context)!.aboutGym,
          'description': AppLocalizations.of(context)!.aboutGymDesc,
        },
      if (projet.hasPlayground)
        {
          'icon': Icons.games,
          'title': AppLocalizations.of(context)!.aboutPlayground,
          'description': AppLocalizations.of(context)!.aboutPlaygroundDesc,
        },
      if (projet.hasSecurityService)
        {
          'icon': Icons.security,
          'title': AppLocalizations.of(context)!.aboutSecurity,
          'description': AppLocalizations.of(context)!.aboutSecurityDesc,
        },
      if (projet.hasGarden)
        {
          'icon': Icons.nature,
          'title': AppLocalizations.of(context)!.aboutGarden,
          'description': AppLocalizations.of(context)!.aboutGardenDesc,
        },
      if (projet.hasSharedTerrace)
        {
          'icon': Icons.deck,
          'title': AppLocalizations.of(context)!.aboutTerrace,
          'description': AppLocalizations.of(context)!.aboutTerraceDesc,
        },
      if (projet.hasBicycleStorage)
        {
          'icon': Icons.pedal_bike,
          'title': AppLocalizations.of(context)!.aboutBicycle,
          'description': AppLocalizations.of(context)!.aboutBicycleDesc,
        },
      if (projet.hasLaundryRoom)
        {
          'icon': Icons.local_laundry_service,
          'title': AppLocalizations.of(context)!.aboutLaundry,
          'description': AppLocalizations.of(context)!.aboutLaundryDesc,
        },
      if (projet.hasStorageRooms)
        {
          'icon': Icons.storage,
          'title': AppLocalizations.of(context)!.aboutStorage,
          'description': AppLocalizations.of(context)!.aboutStorageDesc,
        },
      if (projet.hasWasteDisposalArea)
        {
          'icon': Icons.delete,
          'title': AppLocalizations.of(context)!.aboutWaste,
          'description': AppLocalizations.of(context)!.aboutWasteDesc,
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
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progression,
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
