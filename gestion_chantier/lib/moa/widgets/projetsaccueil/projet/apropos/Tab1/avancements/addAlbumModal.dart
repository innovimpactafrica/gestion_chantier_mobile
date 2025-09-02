// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/services/AlbumService.dart';
import 'package:gestion_chantier/moa/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddAlbumModal extends StatefulWidget {
  final VoidCallback? onAlbumAdded;
  final RealEstateModel? projet;

  const AddAlbumModal({super.key, this.onAlbumAdded, this.projet});

  @override
  State<AddAlbumModal> createState() => _AddAlbumModalState();

  // Méthode statique pour afficher le modal
  static void show(
    BuildContext context, {
    VoidCallback? onAlbumAdded,
    RealEstateModel? projet,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              AddAlbumModal(onAlbumAdded: onAlbumAdded, projet: projet),
    );
  }
}

class _AddAlbumModalState extends State<AddAlbumModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ProgressAlbumService _albumService = ProgressAlbumService();

  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Méthode pour la sélection de fichiers réels
  Future<void> _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null) {
        final newImages = result.paths.map((path) => File(path!)).toList();
        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection de fichiers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveAlbum() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez saisir un nom')));
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une image'),
        ),
      );
      return;
    }

    if (widget.projet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Projet non disponible')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _albumService.createAlbum(
        propertyId: widget.projet!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        pictures: _selectedImages,
      );

      if (mounted) {
        Navigator.pop(context);

        if (widget.onAlbumAdded != null) {
          widget.onAlbumAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Album créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  'Albums',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24, color: Colors.grey[600]),
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
                    'Nom',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nom de l\'album',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description field
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Description de l\'album',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photos section
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Zone de sélection de photo avec bordure pointillée orange
                  GestureDetector(
                    onTap: _selectFiles,
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: DottedBorderPainter(
                          radius: 8,
                          color: Colors.orange,
                          dashPattern: const [4, 4],
                          strokeWidth: 1.5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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
                            File image = entry.value;
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(image),
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
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Bouton Enregistrer
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveAlbum,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}
