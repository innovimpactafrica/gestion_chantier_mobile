import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/AlbumModel.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/services/AlbumService.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/utils/constant.dart';

class AlbumsViewer extends StatefulWidget {
  final RealEstateModel projet;

  const AlbumsViewer({super.key, required this.projet});

  @override
  State<AlbumsViewer> createState() => _AlbumsViewerState();
}

class _AlbumsViewerState extends State<AlbumsViewer> {
  final ProgressAlbumService _albumService = ProgressAlbumService();
  List<ProgressAlbum> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final albums = await _albumService.getAlbumsByProperty(widget.projet.id);
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: HexColor('#FF5C02')),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAlbums, child: Text('Réessayer')),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucun album trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Créez votre premier album pour commencer',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          return _buildAlbumCard(album);
        },
      ),
    );
  }

  Widget _buildAlbumCard(ProgressAlbum album) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de l'album
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: HexColor('#FF5C02').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: HexColor('#FF5C02'),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        album.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      album.photoCount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: HexColor('#FF5C02'),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      album.formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Images de l'album
          if (album.hasPhotos) ...[
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount:
                    album.pictures.length > 3 ? 3 : album.pictures.length,
                itemBuilder: (context, index) {
                  final imageUrl =
                      '${APIConstants.API_BASE_URL_IMG}${album.pictures[index]}';
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Gérer l'erreur de chargement d'image
                        },
                      ),
                    ),
                    child:
                        index == 2 && album.pictures.length > 3
                            ? Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+${album.pictures.length - 3}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            : null,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],

          // Bouton pour voir plus
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewAlbumDetails(album),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: HexColor('#FF5C02')),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Voir l\'album',
                      style: TextStyle(
                        color: HexColor('#FF5C02'),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showAlbumOptions(album),
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  void _viewAlbumDetails(ProgressAlbum album) {
    // Navigation vers la vue détaillée de l'album
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(album.name),
            content: Text('Vue détaillée de l\'album ${album.name}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _showAlbumOptions(ProgressAlbum album) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Modifier'),
                  onTap: () {
                    Navigator.pop(context);
                    // Logique de modification
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Partager'),
                  onTap: () {
                    Navigator.pop(context);
                    // Logique de partage
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(album);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(ProgressAlbum album) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Supprimer l\'album'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer l\'album "${album.name}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _albumService.deleteAlbum(album.id);
                    _loadAlbums(); // Recharger la liste
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Album supprimé avec succès')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la suppression: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Supprimer'),
              ),
            ],
          ),
    );
  }
}
