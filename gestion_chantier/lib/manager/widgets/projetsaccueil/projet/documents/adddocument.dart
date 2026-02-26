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
  final DocumentsBloc? bloc; // Nouveau paramètre pour recevoir le bloc existant

  const AddDocumentModal({
    super.key,
    this.onDocumentAdded,
    this.projet,
    required this.availableTypes,
    this.bloc, // Le bloc optionnel
  });

  @override
  State<AddDocumentModal> createState() => _AddDocumentModalState();

  static void show(
      BuildContext context, {
        VoidCallback? onDocumentAdded,
        required List<UnitParametre> availableTypes,
        RealEstateModel? projet,
        DocumentsBloc? bloc, // Nouveau paramètre
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        // Si un bloc est fourni, on l'utilise, sinon on en crée un nouveau
        Widget modal = AddDocumentModal(
          onDocumentAdded: onDocumentAdded,
          availableTypes: availableTypes,
          projet: projet,
          bloc: bloc,
        );

        // Si aucun bloc n'est fourni, on enveloppe dans un BlocProvider
        if (bloc == null) {
          return BlocProvider(
            create: (context) => DocumentsBloc(documentRepository: DocumentRepository()),
            child: modal,
          );
        } else {
          return modal;
        }
      },
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de document',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300,
              child: ListView(
                children: widget.availableTypes.map(
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
                ).toList(),
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
        const SnackBar(content: Text('Erreur lors de la sélection du fichier')),
      );
    }
  }

  void _saveDocument() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }

    if (_selectedDocumentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type de document')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un fichier')),
      );
      return;
    }

    if (widget.projet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Projet non défini')));
      return;
    }

    // Utiliser le bloc fourni ou le bloc du contexte
    final documentsBloc = widget.bloc ?? context.read<DocumentsBloc>();

    documentsBloc.add(
      AddDocument(
        title: _titleController.text.trim(),
        file: _selectedFile!,
        description: _descriptionController.text.trim(),
        realEstatePropertyId: widget.projet!.id,
        typeId: _selectedDocumentType!.id,
        startDate: DateFormatter.formatToApiDate(DateTime.now()),
        endDate: DateFormatter.formatToApiDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser le bloc fourni ou celui du contexte
    final documentsBloc = widget.bloc ?? context.read<DocumentsBloc>();

    return BlocListener<DocumentsBloc, DocumentsState>(
      bloc: documentsBloc, // Spécifier le bloc à écouter
      listenWhen: (previous, current) =>
      current is DocumentAdded || current is DocumentAddError,
      listener: (context, state) {
        if (!mounted) return;

        if (state is DocumentAdded) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document ajouté avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onDocumentAdded?.call();
        }

        if (state is DocumentAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child:  Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                bloc: documentsBloc, // Spécifier le bloc à utiliser
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre field
                          const Text(
                            'Titre',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
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
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Type de document field
                          const Text(
                            'Type de document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap:
                            state is! DocumentAdding
                                ? _selectDocumentType
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: HexColor('#CBD5E1')),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedDocumentType?.label ?? 'Sélectionner',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDocumentType != null
                                          ? const Color(0xFF333333)
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

                          const SizedBox(height: 14),

                          // Document field
                          const Text(
                            'Document',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap:
                            state is! DocumentAdding ? _selectFile : null,
                            child: CustomPaint(
                              painter: DottedBorderPainter(
                                radius: 8,
                                color: HexColor('#FF5C02').withOpacity(0.5),
                                dashPattern: const [6, 4],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
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
                                            Icons.upload_file,
                                            color: HexColor('#FF5C02'),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
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

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Text(
                                        _selectedFileName ?? 'Aucun fichier choisi',
                                        style: TextStyle(
                                          color: _selectedFileName != null
                                              ? Colors.black87
                                              : Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: _selectedFileName != null
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

                          const SizedBox(height: 12),

                          // Description field
                          const Text(
                            'Description (optionnel)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
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

                          const SizedBox(height: 20),

                          // Enregistrer button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed:
                              state is! DocumentAdding
                                  ? _saveDocument
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('#1A365D'),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                              state is DocumentAdding
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Ajout en cours...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
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