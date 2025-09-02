import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestion_chantier/manager/models/UnitParametre.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/date_formatter.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_bloc.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_event.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_state.dart';
import 'dart:io';

class AddDocumentModal extends StatefulWidget {
  final VoidCallback? onDocumentAdded;
  final RealEstateModel? projet;
  final List<UnitParametre> availableTypes;

  const AddDocumentModal({
    super.key,
    this.onDocumentAdded,
    this.projet,
    required this.availableTypes,
  });

  @override
  State<AddDocumentModal> createState() => _AddDocumentModalState();

  // Méthode statique pour afficher le modal
  static void show(
    BuildContext context, {
    VoidCallback? onDocumentAdded,
    required List<UnitParametre> availableTypes,
    RealEstateModel? projet,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider(
            create:
                (context) =>
                    DocumentsBloc(documentRepository: DocumentRepository()),
            child: AddDocumentModal(
              onDocumentAdded: onDocumentAdded,
              availableTypes: availableTypes,
              projet: projet,
            ),
          ),
    );
  }
}

class _AddDocumentModalState extends State<AddDocumentModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  UnitParametre? _selectedDocumentType;
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDocumentType() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de document',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...widget.availableTypes.map(
                  (type) => ListTile(
                    title: Text(type.label),
                    subtitle: Text(type.code),
                    onTap: () {
                      setState(() {
                        _selectedDocumentType = type;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
        print('🔍 Fichier sélectionné: ${_selectedFile?.path}');
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection du fichier: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du fichier')),
      );
    }
  }

  void _saveDocument() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }

    if (_selectedDocumentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un type de document')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un fichier')),
      );
      return;
    }

    if (widget.projet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: Projet non défini')));
      return;
    }

    // Ajouter le document via le bloc
    context.read<DocumentsBloc>().add(
      AddDocument(
        title: _titleController.text.trim(),
        file: _selectedFile!,
        description: _descriptionController.text.trim(),
        realEstatePropertyId: widget.projet!.id,
        typeId: _selectedDocumentType!.id,
        startDate: DateFormatter.formatToApiDate(DateTime.now()),
        endDate: DateFormatter.formatToApiDate(
          DateTime.now().add(Duration(days: 30)),
        ),
      ),
    );

    // Le modal ne se ferme plus automatiquement
    // La fermeture sera gérée par le BlocListener après succès
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentsBloc, DocumentsState>(
      listener: (context, state) {
        if (state is DocumentAdded) {
          // Fermer le modal
          Navigator.pop(context);

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document ajouté avec succès: ${state.document.title}',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Callback pour notifier que le document a été ajouté
          if (widget.onDocumentAdded != null) {
            widget.onDocumentAdded!();
          }
        } else if (state is DocumentAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
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
                    'Nouveau document',
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
              child: BlocBuilder<DocumentsBloc, DocumentsState>(
                builder: (context, state) {
                  return SingleChildScrollView(
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
                              controller: _titleController,
                              enabled: state is! DocumentAdding,
                              decoration: InputDecoration(
                                hintText: 'Ex: Fiche de Suivi des Travaux',
                                hintStyle: TextStyle(
                                  color: HexColor('#6B7280'),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          SizedBox(height: 14),

                          // Type de document field
                          Text(
                            'Type de document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HexColor('#333333'),
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap:
                                state is! DocumentAdding
                                    ? _selectDocumentType
                                    : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: HexColor('#CBD5E1')),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDocumentType?.label ??
                                        'Sélectionner',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _selectedDocumentType != null
                                              ? HexColor('#333333')
                                              : HexColor('#6B7280'),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: HexColor('#6B7280'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 14),

                          // Document field
                          Text(
                            'Document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap:
                                state is! DocumentAdding ? _selectFile : null,
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
                                        color: HexColor(
                                          '#FF5C02',
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.upload_file,
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
                                        _selectedFileName ??
                                            'Aucun fichier choisi',
                                        style: TextStyle(
                                          color:
                                              _selectedFileName != null
                                                  ? Colors.black87
                                                  : Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight:
                                              _selectedFileName != null
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
                              controller: _descriptionController,
                              enabled: state is! DocumentAdding,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: 'Saisir',
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
                              onPressed:
                                  state is! DocumentAdding
                                      ? _saveDocument
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('#1A365D'),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  state is DocumentAdding
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Ajout en cours...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
