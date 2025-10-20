// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/services/IncidentService.dart';
import 'package:gestion_chantier/moa/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddSignalementModal extends StatefulWidget {
  final int propertyId;

  const AddSignalementModal({super.key, required this.propertyId});

  @override
  State<AddSignalementModal> createState() => _AddSignalementModalState();

  // Méthode statique pour afficher le modal
  static Future<void> show(BuildContext context, {required int propertyId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSignalementModal(propertyId: propertyId),
    );
  }
}

class _AddSignalementModalState extends State<AddSignalementModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<File> _compressImage(File file) async {
    final targetPath = file.path + '_compressed.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    if (result == null) return file;
    return File(result.path);
  }

  Future<void> _selectFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      List<File> compressed = [];
      for (final x in picked) {
        final file = File(x.path);
        final compressedFile = await _compressImage(file);
        compressed.add(compressedFile);
      }
      setState(() {
        _selectedImages.addAll(compressed);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveSignalement() async {
    print('[DEBUG] Début _saveSignalement');
    if (_titleController.text.trim().isEmpty) {
      print('[DEBUG] Titre vide');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez saisir un titre')));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      print('[DEBUG] Commentaire vide');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un commentaire')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      print('[DEBUG] Appel IncidentService.addIncident');
      await IncidentService().addIncident(
        title: _titleController.text.trim(),
        description: _commentController.text.trim(),
        propertyId: widget.propertyId,
        pictures: _selectedImages,
      );
      print('[DEBUG] Signalement ajouté avec succès');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement ajouté avec succès')),
      );
    } catch (e) {
      print('[DEBUG] Erreur lors de l\'ajout du signalement: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
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
                padding: const EdgeInsets.all(22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Signalement',
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
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
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
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          decoration: InputDecoration(
                            hintText: 'Saisir',
                            hintStyle: TextStyle(color: HexColor('#6B7280')),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Commentaire field
                      const Text(
                        'Commentaire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: HexColor('#CBD5E1')),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Saisir',

                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Photos section
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Zone de sélection de photo avec bordure pointillée
                      GestureDetector(
                        onTap: _selectFile,
                        child: SizedBox(
                          height: 90,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: DottedBorderPainter(
                              radius: 8,
                              color: HexColor('#FF5C02').withOpacity(0.5),
                              dashPattern: const [2, 2],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: HexColor('#FF5C02'),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Photo',
                                    style: TextStyle(
                                      color: HexColor('#666666'),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Affichage des images sélectionnées
                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _selectedImages.asMap().entries.map((entry) {
                                int index = entry.key;
                                File imageFile = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(imageFile),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Enregistrer button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveSignalement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor('#1A365D'),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Enregistrer le signalement',
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
        ],
      ),
    );
  }
}
