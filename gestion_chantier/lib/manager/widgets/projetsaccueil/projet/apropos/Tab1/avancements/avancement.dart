// widgets/tabs/avancement_tab.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/rapport/RapportBloc.dart';
import 'package:gestion_chantier/manager/bloc/rapport/RapportEvent.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/repository/RapportRepository.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/addAlbumModal.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/rapports_widget.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/apropos/Tab1/avancements/vue_generale_widget.dart';
import 'package:gestion_chantier/ouvrier/utils/ToastUtils.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../../bloc/rapport/RapportState.dart';
import 'albums_viewer.dart';

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
  final GlobalKey<VueGeneraleWidgetState> _vuegKey = GlobalKey();
  final GlobalKey<RapportsWidgetBlocState> _rapportsKey =
      GlobalKey(); // AJOUTER
  late final RapportBloc rapportBloc;

  @override
  void initState() {
    super.initState();
    rapportBloc = RapportBloc(
      repository: RapportRepository(),
    ); // Create bloc instance

    // Écouter les succès d'ajout de rapport
    rapportBloc.stream.listen((state) {
      if (state is RapportAddedSuccess) {
        // Rafraîchir RapportsWidgetBloc quand un rapport est ajouté
        _rapportsKey.currentState?.refresh();
      }
    });
  }

  @override
  void dispose() {
    rapportBloc.close(); // Close bloc when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the bloc to the widget tree
    return BlocProvider.value(
      value: rapportBloc,
      child: Scaffold(
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
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent * 0.9) {
              _rapportsKey.currentState?.loadMore();
            }
            return false;
          },
          child:SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                // Section des onglets Vue générale / Rapports
                _buildViewTabs(),
                SizedBox(height: 24),

                // Contenu conditionnel selon l'onglet sélectionné
                selectedView == VIEW_GENERAL
                    ? VueGeneraleWidget(
                      key: _vuegKey,
                      projet: widget.projet,
                      onRefresh: () {
                        setState(() {});
                      },
                    )
                    : RapportsWidgetBloc(
                      key: _rapportsKey,
                      projet: widget.projet,
                    ),
              ],
            ),
          ),
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
        _vuegKey.currentState?.reloadAlbums();
        setState(() {});
      },
      projet: widget.projet,
    );
  }

  void _showAddReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: rapportBloc,
          child: _AddRapportBottomSheet(
            projetId: widget.projet.id,
            rapportBloc: rapportBloc, // Pass bloc as parameter
          ),
        );
      },
    );
  }
}

class _AddRapportBottomSheet extends StatefulWidget {
  final int projetId;
  final RapportBloc rapportBloc; // Add bloc parameter

  const _AddRapportBottomSheet({
    required this.projetId,
    required this.rapportBloc,
  });

  @override
  State<_AddRapportBottomSheet> createState() => _AddRapportBottomSheetState();
}

class _AddRapportBottomSheetState extends State<_AddRapportBottomSheet> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  File? selectedFile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const SizedBox(height: 12),

            /// HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nouveau rapport',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITRE
                    const Text('Titre'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Rapport d\'avancement',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// DOCUMENT
                    const Text('Document (PDF, Word, Image)'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'doc',
                            'docx',
                            'png',
                            'jpg',
                            'jpeg',
                          ],
                        );

                        if (result != null &&
                            result.files.single.path != null) {
                          setState(() {
                            selectedFile = File(result.files.single.path!);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedFile != null
                                    ? selectedFile!.path.split('/').last
                                    : 'Choisir un fichier',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// DESCRIPTION
                    const Text('Description (optionnel)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Description du rapport',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// BOUTON ENREGISTRER
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            ToastUtils.show('Veuillez saisir un titre');
                            return;
                          }

                          if (selectedFile == null) {
                            ToastUtils.show('Veuillez choisir un fichier');
                            return;
                          }

                          /// 🔥 DISPATCH BLOC using the passed bloc
                          widget.rapportBloc.add(
                            AddRapport(
                              titre: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              propertyId: widget.projetId,
                              file: selectedFile!,
                            ),
                          );
                          ToastUtils.show('Rapport Ajouté !!');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Enregistrer'),
                      ),
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
