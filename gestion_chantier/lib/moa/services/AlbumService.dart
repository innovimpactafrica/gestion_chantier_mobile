// services/ProgressAlbumService.dart

import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/AlbumModel.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

import 'package:gestion_chantier/moa/services/api_service.dart';

class ProgressAlbumService {
  final ApiService _apiService = ApiService();

  /// Récupère tous les albums de progression pour une propriété donnée
  Future<List<ProgressAlbum>> getAlbumsByProperty(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/progress-album/by-property/$propertyId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProgressAlbum.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des albums: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère un album spécifique par son ID
  Future<ProgressAlbum> getAlbumById(int albumId) async {
    try {
      final response = await _apiService.dio.get('/progress-album/$albumId');

      if (response.statusCode == 200) {
        return ProgressAlbum.fromJson(response.data);
      } else {
        throw Exception(
          'Erreur lors de la récupération de l\'album: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Compresse une image pour réduire sa taille
  Future<File> _compressImage(File file) async {
    try {
      print('🔍 Compression de l\'image: ${file.path}');

      // Lire le fichier original
      final bytes = await file.readAsBytes();

      // Compresser l'image avec des paramètres modérés
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1024, // Retour à 1024
        minWidth: 1024, // Retour à 1024
        quality: 70, // Retour à 70
        format: CompressFormat.jpeg,
      );

      // Créer un fichier temporaire compressé
      final compressedFile = File('${file.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      print('✅ Image compressée: ${compressedFile.path}');
      print('📊 Taille originale: ${bytes.length} bytes');
      print('📊 Taille compressée: ${compressedBytes.length} bytes');
      print(
        '📊 Réduction: ${((bytes.length - compressedBytes.length) / bytes.length * 100).toStringAsFixed(1)}%',
      );

      return compressedFile;
    } catch (e) {
      print(
        '⚠️ Erreur lors de la compression, utilisation du fichier original: $e',
      );
      return file; // Retourner le fichier original en cas d'erreur
    }
  }

  /// Compresse une liste d'images
  Future<List<File>> _compressImages(List<File> images) async {
    List<File> compressedImages = [];

    for (int i = 0; i < images.length; i++) {
      print('🔄 Compression de l\'image ${i + 1}/${images.length}');
      final compressedImage = await _compressImage(images[i]);
      compressedImages.add(compressedImage);
    }

    return compressedImages;
  }

  /// Crée un nouvel album de progression
  Future<ProgressAlbum> createAlbum({
    required int propertyId,
    required String name,
    required String description,
    required List<File> pictures,
    bool entrance = false,
  }) async {
    try {
      print('🔍 ProgressAlbumService: Création d\'un nouvel album');
      print('🔍 ProgressAlbumService: Propriété ID: $propertyId');
      print('🔍 ProgressAlbumService: Nom: $name');
      print('🔍 ProgressAlbumService: Description: $description');
      print('🔍 ProgressAlbumService: Nombre d\'images: ${pictures.length}');

      // Valider la taille des images (juste pour l'information)
      for (int i = 0; i < pictures.length; i++) {
        final file = pictures[i];
        final size = await file.length();
        final sizeInMB = size / (1024 * 1024);
        print('📊 Image ${i + 1}: ${sizeInMB.toStringAsFixed(2)} MB');
      }

      // Compresser les images
      final compressedPictures = await _compressImages(pictures);

      // Créer le FormData selon l'endpoint Swagger
      final formData = FormData.fromMap({
        'realEstatePropertyId': propertyId,
        'name': name,
        'description': description,
        'entrance': entrance,
      });

      // Ajouter les images compressées
      for (int i = 0; i < compressedPictures.length; i++) {
        final file = compressedPictures[i];
        final size = await file.length();
        final sizeInMB = size / (1024 * 1024);
        print('📤 Upload image ${i + 1}: ${sizeInMB.toStringAsFixed(2)} MB');

        formData.files.add(
          MapEntry(
            'pictures',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType: DioMediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      final response = await _apiService.dio.post(
        '/progress-album/save',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data', 'Accept': '*/*'},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('📡 Réponse serveur: ${response.statusCode}');
      if (response.data != null) {
        print('📡 Données: ${response.data}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final album = ProgressAlbum.fromJson(response.data);
        print('✅ Album créé avec succès: ID ${album.id}');

        // Nettoyer les fichiers temporaires compressés
        _cleanupCompressedFiles(compressedPictures);

        return album;
      } else if (response.statusCode == 413) {
        // Nettoyer les fichiers temporaires même en cas d'erreur
        _cleanupCompressedFiles(compressedPictures);
        throw Exception(
          'Les images sont encore trop volumineuses. Veuillez sélectionner des images plus petites ou réduire leur nombre.',
        );
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'avez pas les droits pour créer cet album');
      } else if (response.statusCode == 400) {
        String errorMessage = 'Données invalides';
        if (response.data != null && response.data is Map<String, dynamic>) {
          errorMessage =
              response.data['message'] ??
              response.data['error'] ??
              errorMessage;
        }
        throw Exception(errorMessage);
      } else {
        // Nettoyer les fichiers temporaires même en cas d'erreur
        _cleanupCompressedFiles(compressedPictures);
        throw Exception(
          'Erreur lors de la création de l\'album: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      print('❌ Erreur inattendue lors de la création de l\'album: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour un album existant
  Future<ProgressAlbum> updateAlbum({
    required int albumId,
    String? phaseName,
    String? description,
    List<String>? pictures,
    bool? entrance,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (phaseName != null) data['phaseName'] = phaseName;
      if (description != null) data['description'] = description;
      if (pictures != null) data['pictures'] = pictures;
      if (entrance != null) data['entrance'] = entrance;

      final response = await _apiService.dio.put(
        '/progress-album/$albumId',
        data: data,
      );

      if (response.statusCode == 200) {
        return ProgressAlbum.fromJson(response.data);
      } else {
        throw Exception(
          'Erreur lors de la mise à jour de l\'album: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Supprime un album
  Future<bool> deleteAlbum(int albumId) async {
    try {
      print('🗑️ Suppression de l\'album ID: $albumId');

      final response = await _apiService.dio.delete(
        '/progress-album/delete/$albumId',
      );

      print('📡 Réponse serveur: ${response.statusCode}');
      if (response.data != null) {
        print('📡 Données: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Album supprimé avec succès: ID $albumId');
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'avez pas les droits pour supprimer cet album');
      } else if (response.statusCode == 404) {
        throw Exception('Album non trouvé');
      } else {
        throw Exception(
          'Erreur lors de la suppression de l\'album: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      print('❌ Erreur inattendue lors de la suppression de l\'album: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Ajoute des photos à un album existant
  Future<ProgressAlbum> addPhotosToAlbum({
    required int albumId,
    required List<String> newPictures,
  }) async {
    try {
      // D'abord récupérer l'album existant
      final existingAlbum = await getAlbumById(albumId);

      // Fusionner les nouvelles photos avec les existantes
      final updatedPictures = [...existingAlbum.pictures, ...newPictures];

      // Mettre à jour l'album
      return await updateAlbum(albumId: albumId, pictures: updatedPictures);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout des photos: $e');
    }
  }

  /// Supprime des photos d'un album
  Future<ProgressAlbum> removePhotosFromAlbum({
    required int albumId,
    required List<String> picturesToRemove,
  }) async {
    try {
      // D'abord récupérer l'album existant
      final existingAlbum = await getAlbumById(albumId);

      // Supprimer les photos spécifiées
      final updatedPictures =
          existingAlbum.pictures
              .where((picture) => !picturesToRemove.contains(picture))
              .toList();

      // Mettre à jour l'album
      return await updateAlbum(albumId: albumId, pictures: updatedPictures);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des photos: $e');
    }
  }

  /// Récupère les albums groupés par phase
  Future<Map<String, List<ProgressAlbum>>> getAlbumsGroupedByPhase(
    int propertyId,
  ) async {
    try {
      final albums = await getAlbumsByProperty(propertyId);
      final Map<String, List<ProgressAlbum>> groupedAlbums = {};

      for (final album in albums) {
        final phaseName = album.name;
        if (!groupedAlbums.containsKey(phaseName)) {
          groupedAlbums[phaseName] = [];
        }
        groupedAlbums[phaseName]!.add(album);
      }

      // Trier les albums de chaque phase par date
      groupedAlbums.forEach((phase, albums) {
        albums.sort((a, b) => b.lastUpdatedDate.compareTo(a.lastUpdatedDate));
      });

      return groupedAlbums;
    } catch (e) {
      throw Exception('Erreur lors du groupement des albums: $e');
    }
  }

  /// Récupère les statistiques des albums pour une propriété
  Future<AlbumStats> getAlbumStats(int propertyId) async {
    try {
      final albums = await getAlbumsByProperty(propertyId);

      int totalAlbums = albums.length;
      int totalPhotos = albums.fold(
        0,
        (sum, album) => sum + album.pictures.length,
      );
      int albumsWithPhotos = albums.where((album) => album.hasPhotos).length;

      Map<String, int> photosByPhase = {};
      for (final album in albums) {
        final phaseName = album.name;
        photosByPhase[phaseName] =
            (photosByPhase[phaseName] ?? 0) + album.pictures.length;
      }

      return AlbumStats(
        totalAlbums: totalAlbums,
        totalPhotos: totalPhotos,
        albumsWithPhotos: albumsWithPhotos,
        photosByPhase: photosByPhase,
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// Gestion des erreurs Dio
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Délai de connexion dépassé');
      case DioExceptionType.sendTimeout:
        return Exception('Délai d\'envoi dépassé');
      case DioExceptionType.receiveTimeout:
        return Exception('Délai de réception dépassé');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Erreur serveur';
        return Exception('Erreur $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Requête annulée');
      case DioExceptionType.connectionError:
        return Exception('Erreur de connexion');
      default:
        return Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Nettoyer les fichiers temporaires compressés
  void _cleanupCompressedFiles(List<File> compressedFiles) {
    try {
      for (final file in compressedFiles) {
        if (file.existsSync()) {
          file.deleteSync();
          print('🗑️ Fichier temporaire supprimé: ${file.path}');
        }
      }
    } catch (e) {
      print('⚠️ Erreur lors du nettoyage des fichiers temporaires: $e');
    }
  }
}

/// Classe pour les statistiques des albums
class AlbumStats {
  final int totalAlbums;
  final int totalPhotos;
  final int albumsWithPhotos;
  final Map<String, int> photosByPhase;

  AlbumStats({
    required this.totalAlbums,
    required this.totalPhotos,
    required this.albumsWithPhotos,
    required this.photosByPhase,
  });

  double get averagePhotosPerAlbum {
    return totalAlbums > 0 ? totalPhotos / totalAlbums : 0.0;
  }

  double get albumsWithPhotosPercentage {
    return totalAlbums > 0 ? (albumsWithPhotos / totalAlbums) * 100 : 0.0;
  }
}
