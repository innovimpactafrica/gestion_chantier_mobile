// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_bloc.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_event.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_state.dart';
import 'package:gestion_chantier/manager/models/documents.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/UnitParametre.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/appbar.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/documents/adddocument.dart';
import 'package:gestion_chantier/shared/utils/openFileUtil.dart';
import 'document_search_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_bloc.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_event.dart';
import 'package:gestion_chantier/manager/bloc/documents/documents_state.dart';
import 'package:gestion_chantier/manager/models/documents.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/UnitParametre.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/manager/utils/date_formatter.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/appbar.dart';
import 'document_search_page.dart';

class DocumentsPage extends StatefulWidget {
  final RealEstateModel? projet;

  const DocumentsPage({super.key, this.projet});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<DocumentModel> documents = [];
  List<DocumentModel> recentDocuments = [];
  List<DocumentModel> filteredDocuments = [];
  List<UnitParametre> documentTypes = [];
  bool isLoadingTypes = true;
  bool isLoadingDocuments = false;
  String searchQuery = '';
  bool isSearching = false;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    filteredDocuments = [];
  }

  void _onDocumentAdded() {
    context.read<DocumentsBloc>().add(LoadDocuments(widget.projet!.id));
    setState(() {
      searchQuery = '';
      isSearching = false;
    });
  }

  List<DocumentModel> _generateExampleDocuments() {
    final List<DocumentModel> exampleDocs = [];

    for (int i = 0; i < documentTypes.length && i < 10; i++) {
      final type = documentTypes[i];
      exampleDocs.add(
        DocumentModel(
          id: i + 1,
          title: type.label,
          file: '${type.code.toLowerCase()}_document.pdf',
          description: 'Document de type ${type.label}',
          type: type.code,
          startDate: DateTime.now().subtract(Duration(days: i * 7)),
          endDate: DateTime.now().add(Duration(days: 30)),
        ),
      );
    }

    return exampleDocs;
  }

  String _formatDateToFrench(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    final months = [
      '',
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'jun',
      'jul',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc',
    ];

    if (difference < 30) {
      return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month]}';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month]} ${dateTime.year}';
    }
  }

  UnitParametre? _getDocumentTypeByCode(String code) {
    try {
      return documentTypes.firstWhere((type) => type.code == code);
    } catch (e) {
      return null;
    }
  }

  Future<List<UnitParametre>> searchDocumentTypes(String query) async {
    if (query.isEmpty) {
      return documentTypes;
    }
    return documentTypes
        .where(
          (type) =>
      type.label.toLowerCase().contains(query.toLowerCase()) ||
          type.code.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }

  List<UnitParametre> getAvailableDocumentTypes() {
    return documentTypes;
  }

  String _getExtension(String filePath) {
    final name = filePath.split('/').last.toLowerCase();
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  Widget _getDocumentIcon(String filePath) {
    final ext = _getExtension(filePath);
    String svgAsset;
    if (ext == 'pdf') {
      svgAsset = 'assets/icons/p.svg';
    } else if (['doc', 'docx'].contains(ext)) {
      svgAsset = 'assets/icons/w.svg';
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      svgAsset = 'assets/icons/x.svg';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, color: Colors.purple, size: 24),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.insert_drive_file, color: Colors.grey, size: 24),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(child: SvgPicture.asset(svgAsset, width: 24, height: 24)),
    );
  }

  Color _getDocumentIconColor(String filePath) {
    final ext = _getExtension(filePath);
    if (ext == 'pdf') return Colors.red;
    if (['doc', 'docx'].contains(ext)) return Colors.blue;
    if (['xls', 'xlsx', 'csv'].contains(ext)) return Colors.green;
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) return Colors.purple;
    return Colors.grey;
  }

  String _getDocumentTypeText(String filePath) {
    final ext = _getExtension(filePath);
    if (ext == 'pdf') return 'PDF';
    if (['doc', 'docx'].contains(ext)) return 'DOC';
    if (['xls', 'xlsx', 'csv'].contains(ext)) return 'XLS';
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) return 'IMG';
    return ext.toUpperCase().isNotEmpty ? ext.toUpperCase() : 'FILE';
  }

  String _getFileSize(String fileName) {
    final random = fileName.hashCode % 1000;
    if (random < 100) {
      return '${random + 50}ko';
    } else {
      return '${(random / 100).toStringAsFixed(1)}Mo';
    }
  }

  void _showDocumentOptions(DocumentModel document) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              document.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (document.type != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  document.type!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _buildOptionItem(Icons.visibility, 'Voir', () {
              Navigator.pop(context);
            }),
            _buildOptionItem(Icons.share, 'Partager', () {
              Navigator.pop(context);
            }),
            _buildOptionItem(Icons.download, 'Télécharger', () {
              Navigator.pop(context);
            }),
            _buildOptionItem(Icons.edit, 'Renommer', () {
              Navigator.pop(context);
              _showRenameDialog(document);
            }),
            _buildOptionItem(Icons.delete, 'Supprimer', () {
              Navigator.pop(context);
              _showDeleteConfirmation(document);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.black),
      ),
      onTap: onTap,
    );
  }

  void _showRenameDialog(DocumentModel document) {
    final controller = TextEditingController(text: document.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer le document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nouveau nom',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document renommé')));
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${document.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                documents.removeWhere((d) => d.id == document.id);
                recentDocuments.removeWhere((d) => d.id == document.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document supprimé')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog() {
    AddDocumentModal.show(
      context,
      onDocumentAdded: _onDocumentAdded,
      availableTypes: documentTypes,
      projet: widget.projet,
    );
  }

  void _filterDocuments() {
    List<DocumentModel> baseList = documents;
    if (selectedType != null && selectedType!.isNotEmpty) {
      baseList = baseList.where((doc) => doc.type == selectedType).toList();
    }
    if (searchQuery.isEmpty) {
      setState(() {
        filteredDocuments = baseList;
        isSearching = false;
      });
    } else {
      setState(() {
        filteredDocuments =
            baseList.where((doc) {
              return doc.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();
        isSearching = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentsBloc(documentRepository: DocumentRepository())
        ..add(LoadDocuments(widget.projet!.id!))
        ..add(LoadDocumentTypes()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
          children: [
            CustomProjectAppBar(
              title: widget.projet?.name ?? 'Documents',
              onBackPressed: () => Navigator.of(context).pop(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 20),
                  tooltip: 'Rechercher des documents',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DocumentSearchPage(documents: documents),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: BlocConsumer<DocumentsBloc, DocumentsState>(
                listener: (context, state) {
                  if (state is DocumentsLoaded) {
                    setState(() {
                      documents = state.documents;
                      recentDocuments = state.documents.take(3).toList();
                      filteredDocuments = state.documents;
                      isLoadingDocuments = false;
                      if (selectedType != null &&
                          !documentTypes.any((t) => t.code == selectedType)) {
                        selectedType = null;
                      }
                    });

                    print(
                      '🔍 DocumentsPage: État local mis à jour avec ${state.documents.length} documents',
                    );
                  } else if (state is DocumentTypesLoaded) {
                    setState(() {
                      documentTypes = state.documentTypes;
                      isLoadingTypes = false;
                    });
                    print(
                      '🔍 DocumentsPage: Types de documents mis à jour: ${state.documentTypes.length}',
                    );
                  } else if (state is DocumentsError) {
                    setState(() {
                      isLoadingDocuments = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is DocumentTypesError) {
                    setState(() {
                      isLoadingTypes = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur types: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is DocumentAdded) {
                    // Recharger les documents après ajout
                    context.read<DocumentsBloc>().add(
                      LoadDocuments(widget.projet!.id),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is DocumentsLoading || state is DocumentTypesLoading) {
                    return _buildLoadingState();
                  } else if (state is DocumentsLoaded) {
                    if (state.documents.isEmpty) {
                      return _buildEmptyState();
                    } else {
                      return _buildDocumentsContentWithState(state.documents);
                    }
                  } else if (state is DocumentsError) {
                    return _buildErrorState(state.message);
                  } else if (state is DocumentTypesError) {
                    return _buildErrorState(state.message);
                  } else {
                    return _buildLoadingState();
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: BlocBuilder<DocumentsBloc, DocumentsState>(
          builder: (context, state) {
            return CustomFloatingButton(
              imagePath: 'assets/icons/plus.svg',
              onPressed: () => AddDocumentModal.show(
                context,
                bloc: context.read<DocumentsBloc>(), // Passer le bloc existant
                onDocumentAdded: _onDocumentAdded,
                availableTypes: documentTypes,
                projet: widget.projet,
              ),
              label: '',
              backgroundColor: HexColor('#FF5C02'),
              elevation: 4.0,
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HexColor('#FF5C02')),
          ),
          const SizedBox(height: 16),
          Text(
            isLoadingTypes
                ? 'Chargement des types de documents...'
                : 'Chargement des documents...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
           Text(
            'Ajoutez vos premiers documents\npour ce projet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (documentTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${documentTypes.length} types de documents disponibles',
              style:  TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DocumentsBloc>().add(
                LoadDocuments(widget.projet!.id),
              );
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsContentWithState(List<DocumentModel> documents) {
    final documentsToShow = filteredDocuments;
    final recentDocuments = documents.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isSearching && documentsToShow.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun document trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun document ne correspond à "$searchQuery"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          isSearching = false;
                          filteredDocuments = documents;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#FF5C02'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Effacer la recherche',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children:
                documentsToShow.asMap().entries.map((entry) {
                  int index = entry.key;
                  DocumentModel document = entry.value;
                  return _buildDocumentItem(document, index);
                }).toList(),
              ),
            ),
            if (recentDocuments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Fichiers récents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recentDocuments.length,
                  itemBuilder: (context, index) {
                    return _buildRecentDocumentCard(recentDocuments[index]);
                  },
                ),
              ),
            ],
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(DocumentModel document, int index) {
    return InkWell(
        onTap: (){
          openFileFromUrl(APIConstants.API_BASE_URL_IMG+document.file, document.file);
        },
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
        index < documents.length - 1
            ? Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _getDocumentIcon(document.file),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.type} • ${_getFileSize(document.file)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              document.startDate != null
                  ? _formatDateToFrench(document.startDate!)
                  : '06 mai',
              style:  TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildRecentDocumentCard(DocumentModel document) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16, bottom: 79),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDocumentOptions(document),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: _buildDocumentPreview(document),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDocumentIconColor(document.file),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getDocumentTypeText(document.file),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _getDocumentIcon(document.file),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(DocumentModel document) {
    final ext = _getExtension(document.file);
    final color = _getDocumentIconColor(document.file);
    final label = _getDocumentTypeText(document.file);
    IconData icon;
    if (ext == 'pdf') {
      icon = Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      icon = Icons.description;
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      icon = Icons.table_chart;
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      icon = Icons.image;
    } else {
      icon = Icons.insert_drive_file;
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
