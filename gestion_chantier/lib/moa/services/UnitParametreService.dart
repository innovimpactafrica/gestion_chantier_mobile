import 'package:dio/dio.dart';
import 'package:gestion_chantier/moa/models/documents.dart';
import 'package:gestion_chantier/moa/models/UnitParametre.dart';
import 'dart:io';

import 'package:gestion_chantier/moa/services/api_service.dart';

class DocumentService {
  final ApiService _apiService = ApiService();

  /// Récupère tous les documents pour une propriété donnée
  /// [propertyId] - L'ID de la propriété
  Future<List<DocumentModel>> getDocumentsByProperty(int propertyId) async {
    try {
      final response = await _apiService.dio.get(
        '/documents/property/$propertyId',
      );

      if (response.statusCode == 200) {
        // Gestion du format de réponse paginé
        if (response.data is Map<String, dynamic> &&
            response.data['content'] != null) {
          // Format paginé: {content: [...], pageable: {...}, ...}
          final List<dynamic> content = response.data['content'];
          final documents =
              content.map((json) => DocumentModel.fromJson(json)).toList();
          return documents;
        } else if (response.data is List) {
          // Format direct: [...]
          final documents =
              (response.data as List)
                  .map((json) => DocumentModel.fromJson(json))
                  .toList();
          return documents;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('❌ DocumentService: Status Code: ${e.response?.statusCode}');
        print('❌ DocumentService: Response Data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print(
        '❌ DocumentService: Erreur inattendue lors de la récupération des documents: $e',
      );
      return [];
    }
  }

  Future<List<DocumentModel>> searchDocuments(
    int propertyId,
    String query,
  ) async {
    try {
      final allDocuments = await getDocumentsByProperty(propertyId);

      if (query.isEmpty) {
        return allDocuments;
      }

      return allDocuments.where((doc) {
        return doc.title.toLowerCase().contains(query.toLowerCase()) ||
            doc.description.toLowerCase().contains(query.toLowerCase()) ||
            (doc.type?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      print('Erreur lors de la recherche des documents: $e');
      return [];
    }
  }

  /// Filtre les documents par type
  /// [propertyId] - L'ID de la propriété
  /// [type] - Le type de document à filtrer
  Future<List<DocumentModel>> getDocumentsByType(
    int propertyId,
    String type,
  ) async {
    try {
      final allDocuments = await getDocumentsByProperty(propertyId);

      return allDocuments.where((doc) {
        return doc.type?.toLowerCase() == type.toLowerCase();
      }).toList();
    } catch (e) {
      print('Erreur lors du filtrage des documents par type: $e');
      return [];
    }
  }

  /// Filtre les documents par période (date de début)
  /// [propertyId] - L'ID de la propriété
  /// [startDate] - Date de début de la période
  /// [endDate] - Date de fin de la période
  Future<List<DocumentModel>> getDocumentsByDateRange(
    int propertyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allDocuments = await getDocumentsByProperty(propertyId);

      return allDocuments.where((doc) {
        if (doc.startDate == null) return false;
        return doc.startDate!.isAfter(startDate.subtract(Duration(days: 1))) &&
            doc.startDate!.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Erreur lors du filtrage des documents par date: $e');
      return [];
    }
  }

  searchDocumentTypes(String query) {}

  /// Récupère tous les types de documents depuis l'API
  Future<List<UnitParametre>> getDocumentTypes() async {
    try {
      final response = await _apiService.dio.get('/documents/types');

      if (response.statusCode == 200) {
        // Gestion du format de réponse paginé
        if (response.data is Map<String, dynamic> &&
            response.data['content'] != null) {
          // Format paginé: {content: [...], pageable: {...}, ...}
          final List<dynamic> content = response.data['content'];
          final documents =
              content.map((json) => UnitParametre.fromJson(json)).toList();
          return documents;
        } else if (response.data is List) {
          // Format direct: [...]
          final documents =
              response.data
                  .map((json) => UnitParametre.fromJson(json))
                  .toList();
          return documents;
        } else {
          return [];
        }
      } else {
        print(
          '❌ DocumentService: Erreur HTTP ${response.statusCode} pour les types de documents',
        );
        return [];
      }
    } catch (e) {
      print(
        '❌ DocumentService: Erreur lors de la récupération des types de documents: $e',
      );
      return [];
    }
  }

  /// Ajoute un nouveau document
  /// [title] - Titre du document
  /// [file] - Fichier à uploader (File)
  /// [description] - Description du document
  /// [realEstatePropertyId] - ID de la propriété
  /// [typeId] - ID du type de document
  /// [startDate] - Date de début (format dd-MM-yyyy)
  /// [endDate] - Date de fin (format dd-MM-yyyy)
  Future<DocumentModel> addDocument({
    required String title,
    required File file,
    required String description,
    required int realEstatePropertyId,
    required int typeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      // Créer le FormData
      final formData = FormData.fromMap({
        'title': title,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'description': description,
        'realEstatePropertyId': realEstatePropertyId,
        'typeId': typeId,
        'startDate': startDate,
        'endDate': endDate,
      });

      final response = await _apiService.dio.post(
        '/documents/add',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final document = DocumentModel.fromJson(response.data);
        return document;
      } else {
        print(
          '❌ DocumentService: Erreur lors de l\'ajout du document: ${response.statusCode}',
        );
        throw Exception(
          'Erreur lors de l\'ajout du document: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('❌ DocumentService: Status Code: ${e.response?.statusCode}');
        print('❌ DocumentService: Response Data: ${e.response?.data}');
      }
      throw Exception(
        'Erreur réseau lors de l\'ajout du document: ${e.message}',
      );
    } catch (e) {
      print(
        '❌ DocumentService: Erreur inattendue lors de l\'ajout du document: $e',
      );
      throw Exception('Erreur inattendue lors de l\'ajout du document: $e');
    }
  }
}
