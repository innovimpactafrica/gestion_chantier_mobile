import 'package:flutter/material.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';
import 'package:gestion_chantier/bet/widgets/etude_detail/add_report_modal.dart';
import 'package:gestion_chantier/bet/services/ReportService.dart';
import 'package:gestion_chantier/moa/widgets/CustomFloatingButton.dart';

// Widget pour le tab Rapports
class RapportsTab extends StatefulWidget {
  final List<BetReportModel> reports;
  final int studyRequestId;
  final int authorId;
  final VoidCallback? onReportAdded;

  const RapportsTab({
    Key? key,
    required this.reports,
    required this.studyRequestId,
    required this.authorId,
    this.onReportAdded,
  }) : super(key: key);

  @override
  State<RapportsTab> createState() => _RapportsTabState();
}

class _RapportsTabState extends State<RapportsTab> {
  List<BetReportModel> _currentReports = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentReports = widget.reports;
  }

  @override
  void didUpdateWidget(RapportsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reports != widget.reports) {
      setState(() {
        _currentReports = widget.reports;
      });
    }
  }

  Future<void> _onReportAdded() async {
    // Vérifier si le widget est encore monté
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Rafraîchir la liste des rapports depuis l'API
      final updatedReports = await ReportService.getReportsByStudy(
        widget.studyRequestId,
      );

      if (mounted) {
        setState(() {
          _currentReports = updatedReports;
          _isRefreshing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapport ajouté avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement des rapports: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rapport ajouté mais erreur lors du rafraîchissement. Rechargez la page.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    if (widget.onReportAdded != null) {
      widget.onReportAdded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text(
                  'Rapports produits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HexColor('#2C3E50'),
                  ),
                ),
              ],
            ),
          ),

          // Liste des rapports
          Expanded(
            child:
                _isRefreshing
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              HexColor('#FF5C02'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rafraîchissement en cours...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _currentReports.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun rapport pour cette étude.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Les rapports apparaîtront ici une fois créés.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _currentReports.length,
                      itemBuilder: (context, index) {
                        final report = _currentReports[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRapportCard(report),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: () {
          AddReportModal.show(
            context,
            studyRequestId: widget.studyRequestId,
            authorId: widget.authorId,
            onReportAdded: _onReportAdded,
          );
        },
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildRapportCard(BetReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icône PDF
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),

          // Titre et détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.displayInfo,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v${report.versionNumber}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
