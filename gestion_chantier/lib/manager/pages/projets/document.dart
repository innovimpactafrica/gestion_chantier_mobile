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

import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/appbar.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/documents/adddocument.dart';
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
    // Initialiser filteredDocuments avec la liste vide pour l'instant
    filteredDocuments = [];
  }

  void _onDocumentAdded() {
    // Recharger les documents via le bloc
    context.read<DocumentsBloc>().add(LoadDocuments(widget.projet!.id));
    // Réinitialiser la recherche
    setState(() {
      searchQuery = '';
      isSearching = false;
    });
  }

  // Génère des documents d'exemple basés sur les types disponibles
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

  // Fonction pour formater la date en français
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

  // Récupère un type de document par son code
  UnitParametre? _getDocumentTypeByCode(String code) {
    try {
      return documentTypes.firstWhere((type) => type.code == code);
    } catch (e) {
      return null;
    }
  }

  // Recherche de types de documents
  Future<List<UnitParametre>> searchDocumentTypes(String query) async {
    // Utiliser les types déjà chargés par le bloc
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

  // Récupère tous les types de documents disponibles (pour le modal d'ajout)
  List<UnitParametre> getAvailableDocumentTypes() {
    return documentTypes;
  }

  Widget _getDocumentIcon(String title) {
    String svgAsset;

    if (title.toLowerCase().contains('pdf') ||
        title.toLowerCase().contains('étude') ||
        title.toLowerCase().contains('rapport')) {
      svgAsset = 'assets/icons/p.svg';
    } else if (title.toLowerCase().contains('word') ||
        title.toLowerCase().contains('suivi') ||
        title.toLowerCase().contains('fiche')) {
      svgAsset = 'assets/icons/w.svg';
    } else if (title.toLowerCase().contains('excel') ||
        title.toLowerCase().contains('contrôle') ||
        title.toLowerCase().contains('qualité')) {
      svgAsset = 'assets/icons/x.svg';
    } else {
      svgAsset = 'assets/icons/w.svg';
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Center(child: SvgPicture.asset(svgAsset, width: 24, height: 24)),
    );
  }

  Color _getDocumentIconColor(String title) {
    if (title.toLowerCase().contains('pdf') ||
        title.toLowerCase().contains('étude') ||
        title.toLowerCase().contains('rapport')) {
      return Colors.red;
    } else if (title.toLowerCase().contains('word') ||
        title.toLowerCase().contains('suivi') ||
        title.toLowerCase().contains('fiche')) {
      return Colors.blue;
    } else if (title.toLowerCase().contains('excel') ||
        title.toLowerCase().contains('contrôle') ||
        title.toLowerCase().contains('qualité')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _getDocumentTypeText(String title) {
    if (title.toLowerCase().contains('pdf') ||
        title.toLowerCase().contains('étude') ||
        title.toLowerCase().contains('rapport')) {
      return 'PDF';
    } else if (title.toLowerCase().contains('word') ||
        title.toLowerCase().contains('suivi') ||
        title.toLowerCase().contains('fiche')) {
      return 'W';
    } else if (title.toLowerCase().contains('excel') ||
        title.toLowerCase().contains('contrôle') ||
        title.toLowerCase().contains('qualité')) {
      return 'X';
    } else {
      return 'DOC';
    }
  }

  // Calcule la taille du fichier (simulée)
  String _getFileSize(String fileName) {
    // Simulation de taille de fichier basée sur le nom
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
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
                SizedBox(height: 20),
                Text(
                  document.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                if (document.type != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                SizedBox(height: 20),
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
      builder:
          (context) => AlertDialog(
            title: Text('Renommer le document'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Nouveau nom',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Document renommé')));
                },
                child: Text('Renommer'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(DocumentModel document) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Supprimer le document'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer "${document.title}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    documents.removeWhere((d) => d.id == document.id);
                    recentDocuments.removeWhere((d) => d.id == document.id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Document supprimé')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Supprimer', style: TextStyle(color: Colors.white)),
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
      create:
          (context) =>
              DocumentsBloc(documentRepository: DocumentRepository())
                ..add(LoadDocuments(widget.projet!.id))
                ..add(LoadDocumentTypes()),
      child: BlocListener<DocumentsBloc, DocumentsState>(
        listener: (context, state) {
          if (state is DocumentsLoaded) {
            setState(() {
              documents = state.documents;
              recentDocuments = state.documents.take(3).toList();
              filteredDocuments = state.documents;
              isLoadingDocuments = false;
              // Sécurisation du filtre
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
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              CustomProjectAppBar(
                title: widget.projet?.name ?? 'Documents',
                onBackPressed: () => Navigator.of(context).pop(),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white, size: 20),
                    tooltip: 'Rechercher des documents',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  DocumentSearchPage(documents: documents),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<DocumentsBloc, DocumentsState>(
                  builder: (context, state) {
                    if (state is DocumentsLoading ||
                        state is DocumentTypesLoading) {
                      return _buildLoadingState();
                    } else if (state is DocumentsLoaded) {
                      if (state.documents.isEmpty) {
                        return _buildEmptyState();
                      } else {
                        // Utiliser directement les documents du bloc
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
          floatingActionButton: CustomFloatingButton(
            imagePath: 'assets/icons/plus.svg',
            onPressed:
                () => AddDocumentModal.show(
                  context,
                  onDocumentAdded: _onDocumentAdded,
                  availableTypes: documentTypes,
                  projet: widget.projet,
                ),
            label: '',
            backgroundColor: HexColor('#FF5C02'),
            elevation: 4.0,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
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
          SizedBox(height: 16),
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
          SizedBox(height: 16),
          Text(
            'Aucun document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ajoutez vos premiers documents\npour ce projet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (documentTypes.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              '${documentTypes.length} types de documents disponibles',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DocumentsBloc>().add(
                LoadDocuments(widget.projet!.id),
              );
            },
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsContentWithState(List<DocumentModel> documents) {
    // Toujours utiliser la liste filtrée pour l'affichage principal
    final documentsToShow = filteredDocuments;
    // Toujours prendre les 3 derniers de la liste globale pour les récents
    final recentDocuments = documents.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                DropdownButton<String?>(
                  value: selectedType,
                  hint: Text('Type', style: TextStyle(fontSize: 14)),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Tous les types'),
                    ),
                    ...documentTypes.map(
                      (type) => DropdownMenuItem<String?>(
                        value: type.code,
                        child: Text(type.label),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      _filterDocuments();
                    });
                  },
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          if (isSearching && documentsToShow.isEmpty) ...[
            // Message quand aucun document n'est trouvé
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Aucun document trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aucun document ne correspond à "$searchQuery"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 16),
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
                      child: Text(
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
              margin: EdgeInsets.symmetric(horizontal: 20),
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
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: Colors.grey[600]),
                    SizedBox(width: 8),
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recentDocuments.length,
                  itemBuilder: (context, index) {
                    return _buildRecentDocumentCard(recentDocuments[index]);
                  },
                ),
              ),
            ],
          ],
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(DocumentModel document, int index) {
    return Container(
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icône du document
            _getDocumentIcon(document.title),
            SizedBox(width: 12),

            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre principal
                  Text(
                    document.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Sous-titre avec auteur et taille
                  Text(
                    'Lamine Niang • ${_getFileSize(document.file)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Date à droite
            Text(
              document.startDate != null
                  ? _formatDateToFrench(document.startDate!)
                  : '06 mai',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocumentCard(DocumentModel document) {
    return Container(
      width: 240,
      margin: EdgeInsets.only(right: 16, bottom: 79),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: _buildDocumentPreview(document),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDocumentIconColor(document.title),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getDocumentTypeText(document.title),
                        style: TextStyle(
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
                  // Icône du document
                  _getDocumentIcon(document.title),
                  SizedBox(width: 12),

                  // Contenu principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre principal
                        Text(
                          document.title,
                          style: TextStyle(
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
    final title = document.title.toLowerCase();

    if (title.contains('word') ||
        title.contains('suivi') ||
        title.contains('fiche')) {
      return _buildWordPreview(document);
    } else if (title.contains('pdf') ||
        title.contains('étude') ||
        title.contains('rapport')) {
      return _buildPdfPreview(document);
    } else if (title.contains('excel') ||
        title.contains('contrôle') ||
        title.contains('qualité')) {
      return _buildExcelPreview(document);
    } else {
      return _buildGenericPreview();
    }
  }

  Widget _buildWordPreview(DocumentModel document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Document Word',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          document.title.length > 25
              ? '${document.title.substring(0, 25)}...'
              : document.title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        ...List.generate(6, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 2),
            height: 2,
            width: double.infinity,
            color: Colors.grey[300],
          );
        }),
      ],
    );
  }

  Widget _buildPdfPreview(DocumentModel document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    'PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Document PDF',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 2, color: Colors.grey[400]),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Container(height: 2, color: Colors.grey[400]),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Container(height: 2, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              ...List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 1.5, color: Colors.grey[300]),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Container(height: 1.5, color: Colors.grey[300]),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Container(height: 1.5, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExcelPreview(DocumentModel document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête Excel
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Center(
                  child: Text(
                    'Xsl',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Feuille Excel',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        // Simulation d'une grille Excel
        Container(
          child: Column(
            children: List.generate(
              5,
              (row) => Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Row(
                  children: List.generate(
                    4,
                    (col) => Expanded(
                      child: Container(
                        height: 12,
                        margin: EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                          color: row == 0 ? Colors.grey[100] : Colors.white,
                        ),
                        child:
                            row == 0
                                ? Center(
                                  child: Container(
                                    height: 2,
                                    width: 20,
                                    color: Colors.grey[400],
                                  ),
                                )
                                : Center(
                                  child: Container(
                                    height: 1.5,
                                    width: 15,
                                    color: Colors.grey[300],
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 20, width: 80, color: Colors.grey[300]),
        SizedBox(height: 8),
        ...List.generate(
          5,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 3),
            height: 2,
            width: 120,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
