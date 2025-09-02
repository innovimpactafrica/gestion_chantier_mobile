// widgets/projet_card.dart
import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/utils/constant.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class MainProjetCard extends StatelessWidget {
  final RealEstateModel projet;
  final VoidCallback onTap;

  const MainProjetCard({super.key, required this.projet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du projet
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Image.network(
                  '${APIConstants.API_BASE_URL_IMG}${projet.plan}',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre du projet
                  Text(
                    projet.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: HexColor('#1A365D'),
                    ),
                  ),

                  SizedBox(height: 8),
                  // Lieu et dates
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: HexColor('#FF5C02'),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          projet.address,
                          style: TextStyle(
                            color: HexColor('#64748B'),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14),
                  // Progression
                  _buildProgressSection(
                    progression: projet.averageProgress.round(),
                    isMain: true,
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

class SecondaryProjetCard extends StatelessWidget {
  final RealEstateModel projet;
  final VoidCallback onTap;

  const SecondaryProjetCard({
    super.key,
    required this.projet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image du projet
            Container(
              height: 119,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Image.network(
                  '${APIConstants.API_BASE_URL_IMG}${projet.plan}',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Contenu du projet
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projet.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#1A365D'),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: HexColor('#FF5C02'),
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            projet.address,
                            style: TextStyle(
                              color: HexColor('#64748B'),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    _buildProgressSection(
                      progression: projet.averageProgress.round(),
                      isMain: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProgressSection({required int progression, required bool isMain}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Progression',
            style: TextStyle(
              fontSize: 13,
              color: HexColor('#64748B'),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$progression%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
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
