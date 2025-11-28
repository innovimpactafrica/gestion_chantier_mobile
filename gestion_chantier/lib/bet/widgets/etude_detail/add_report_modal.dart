import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/services/ReportService.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'dart:io';

class AddReportModal extends StatefulWidget {
  final int studyRequestId;
  final int authorId;
  final VoidCallback? onReportAdded;

  const AddReportModal({
    super.key,
    required this.studyRequestId,
    required this.authorId,
    this.onReportAdded,
  });

  @override
  State<AddReportModal> createState() => _AddReportModalState();

  // Méthode statique pour afficher le modal
  static void show(
    BuildContext context, {
    required int studyRequestId,
    required int authorId,
    VoidCallback? onReportAdded,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddReportModal(
            studyRequestId: studyRequestId,
            authorId: authorId,
            onReportAdded: onReportAdded,
          ),
    );
  }
}

class _AddReportModalState extends State<AddReportModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _versionController.text = '1'; // Version par défaut
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    super.dispose();
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

  Future<void> _saveReport() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un fichier')),
      );
      return;
    }

    final versionNumber = int.tryParse(_versionController.text.trim());
    if (versionNumber == null || versionNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez saisir un numéro de version valide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ReportService.addReport(
        title: _titleController.text.trim(),
        file: _selectedFile!,
        versionNumber: versionNumber,
        studyRequestId: widget.studyRequestId,
        authorId: widget.authorId,
      );

      // Vérifier si le widget est encore monté avant de continuer
      if (!mounted) return;

      // Fermer le modal
      Navigator.pop(context);

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapport ajouté avec succès: ${result['title']}'),
          backgroundColor: Colors.green,
        ),
      );

      // Callback pour notifier que le rapport a été ajouté
      if (widget.onReportAdded != null) {
        widget.onReportAdded!();
      }
    } catch (e) {
      // Vérifier si le widget est encore monté avant de continuer
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: SingleChildScrollView(
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
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Ex: Rapport technique',
                          hintStyle: TextStyle(color: HexColor('#6B7280')),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 14),

                    // Version field
                    Text(
                      'Version',
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
                        controller: _versionController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Ex: v1.0',
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
                      'Document',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isLoading ? null : _selectFile,
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
                                  _selectedFileName ?? 'Aucun fichier choisi',
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

                    SizedBox(height: 20),

                    // Enregistrer button
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#1A365D'),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
            ),
          ),
        ],
      ),
    );
  }
}
