// widgets/tabs/avancement_tab.dart
import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/addAlbumModal.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/rapports_widget.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/vue_generale_widget.dart';

class AvancementTab extends StatefulWidget {
  final RealEstateModel projet;

  const AvancementTab({super.key, required this.projet});

  @override
  _AvancementTabState createState() => _AvancementTabState();
}

class _AvancementTabState extends State<AvancementTab> {
  static const String VIEW_GENERAL = 'Vue générale';
  static const String VIEW_REPORTS = 'Rapports';

  String selectedView = VIEW_GENERAL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#EEEEEE'),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: () {
          if (selectedView == VIEW_GENERAL) {
            _showAddAlbumDialog();
          } else {
            _showAddReportDialog();
          }
        },
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des onglets Vue générale / Rapports
            _buildViewTabs(),
            SizedBox(height: 24),

            // Contenu conditionnel selon l'onglet sélectionné
            selectedView == VIEW_GENERAL
                ? VueGeneraleWidget(
                  projet: widget.projet,
                  onRefresh: () {
                    setState(() {
                      // Forcer le rechargement du widget
                    });
                  },
                )
                : RapportsWidget(projet: widget.projet),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTabs() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        color: HexColor("#FF5C02").withOpacity(0.05),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                VIEW_GENERAL,
                selectedView == VIEW_GENERAL,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                VIEW_REPORTS,
                selectedView == VIEW_REPORTS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        print('Changement vers: $title');
        setState(() {
          selectedView = title;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: 44,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? HexColor('#FF5C02') : HexColor("#333333"),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAlbumDialog() {
    AddAlbumModal.show(
      context,
      onAlbumAdded: () {
        // Forcer le rechargement de la vue générale
        setState(() {
          // Cela va recréer le VueGeneraleWidget et recharger les albums
        });
      },
      projet: widget.projet,
    );
  }

  void _showAddReportDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with close button
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveau rapport',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 28,
                        color: HexColor('#231F20'),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre field
                      Text(
                        'Titre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: HexColor('#333333'),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: HexColor('#CBD5E1')),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Ex: Rapport d\'avancement',
                            hintStyle: TextStyle(color: HexColor('#6B7280')),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      SizedBox(height: 14),

                      // Document field
                      Text(
                        'Document PDF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          print('Sélection de fichier PDF');
                          setState(() {
                            selectedFileName =
                                'rapport_avancement.pdf'; // Simulation
                          });
                        },
                        child: CustomPaint(
                          painter: DottedBorderPainter(
                            radius: 8,
                            color: HexColor('#FF5C02').withOpacity(0.5),
                            dashPattern: [6, 4],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // Bouton "Choisir un fichier"
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: HexColor('#FF5C02').withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        color: HexColor('#FF5C02'),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Choisir un fichier',
                                        style: TextStyle(
                                          color: HexColor('#FF5C02'),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Texte du fichier sélectionné
                                Expanded(
                                  child: Text(
                                    selectedFileName ?? 'Aucun fichier choisi',
                                    style: TextStyle(
                                      color:
                                          selectedFileName != null
                                              ? Colors.black87
                                              : Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight:
                                          selectedFileName != null
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Description field
                      Text(
                        'Description (optionnel)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: HexColor('#CBD5E1')),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: descriptionController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Saisir la description du rapport',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Enregistrer button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Veuillez saisir un titre'),
                                ),
                              );
                              return;
                            }

                            print(
                              'Création rapport: ${titleController.text} - ${descriptionController.text}',
                            );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor('#1A365D'),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
