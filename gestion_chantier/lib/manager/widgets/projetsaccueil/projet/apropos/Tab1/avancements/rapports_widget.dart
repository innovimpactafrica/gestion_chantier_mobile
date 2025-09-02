import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/models/Rapport.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/services/RapportService.dart';

class RapportsWidget extends StatefulWidget {
  final RealEstateModel projet;

  const RapportsWidget({super.key, required this.projet});

  @override
  _RapportsWidgetState createState() => _RapportsWidgetState();
}

class _RapportsWidgetState extends State<RapportsWidget> {
  late Future<List<RapportModel>> _rapportsFuture;
  final RapportService _rapportService = RapportService();

  @override
  void initState() {
    super.initState();
    _rapportsFuture = _rapportService.getAlbumsByProperty(widget.projet.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('rapports_container'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône
          Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Rapports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Liste des rapports
          FutureBuilder<List<RapportModel>>(
            future: _rapportsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildNoReportsWidget();
              }

              return _buildReportsList(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Impossible de charger les rapports. Veuillez réessayer plus tard.',
            style: TextStyle(color: Colors.red[600]),
          ),
          if (error.contains('Map')) // Message spécifique pour cette erreur
            Text(
              'Erreur technique: Format de données incorrect',
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildNoReportsWidget() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[600], size: 20),
          SizedBox(width: 8),
          Text(
            'Aucun rapport disponible pour ce projet',
            style: TextStyle(
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<RapportModel> rapports) {
    return Column(
      children: rapports.map((rapport) => _buildReportItem(rapport)).toList(),
    );
  }

  Widget _buildReportItem(RapportModel rapport) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          print('Ouverture du rapport: ${rapport.title}');
          // TODO: Implémenter l'ouverture/le téléchargement du PDF
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Icône PDF
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),

            // Informations du rapport
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rapport.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${rapport.propertyType.typeName} • ${_formatFileSize(rapport.pdfUrl)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Date et icône de téléchargement
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(rapport.lastUpdated),
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                SizedBox(height: 4),
                Icon(
                  Icons.download_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _formatFileSize(String pdfUrl) {
    // TODO: Implémenter une logique pour obtenir la taille réelle du fichier
    // Pour l'instant, on retourne une taille fictive
    return '${pdfUrl.length ~/ 1000}ko'; // Approximation basée sur la longueur de l'URL
  }
}
