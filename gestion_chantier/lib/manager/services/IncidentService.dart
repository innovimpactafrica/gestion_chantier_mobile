import 'package:gestion_chantier/manager/models/IncidentAnalysisModel.dart';
import 'package:gestion_chantier/manager/models/IncidentModel.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class IncidentService {
  final ApiService _apiService = ApiService();

  Future<IncidentResponse> getIncidents({
    required int propertyId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/incidents?propertyId=$propertyId&page=$page&size=$size',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return IncidentResponse.fromJson(data);
      } else {
        throw Exception(
          'Erreur lors de la récupération des incidents: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  String getImageUrl(String imageName) {
    return '${APIConstants.API_BASE_URL}/images/$imageName';
  }

  Future<void> addIncident({
    required String title,
    required String description,
    int? propertyId,
    required List<File> pictures,
  }) async {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
    };

    if (propertyId != null && propertyId > 0) {
      map['propertyId'] = propertyId;
    }

    if (pictures.isNotEmpty) {
      map['pictures'] = [
        for (final file in pictures)
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
      ];
    }

    final formData = FormData.fromMap(map);

    try {
      final response = await _apiService.dio.post(
        '/incidents/save',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'ajout du signalement');
      }
    } on DioException catch (e) {
      print('[IncidentService] Erreur ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception('Erreur ${e.response?.statusCode}: ${e.response?.data}');
    }
  }

  Future<IncidentAnalysisModel?> getIncidentRapport(int incidentId) async {
    try {
      final response = await _apiService.dio.get('/incident-rapports/by-incident/$incidentId');
      if (response.statusCode == 200 && response.data != null) {
        return IncidentAnalysisModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> generateIncidentRapport(int incidentId) async {
    try {
      await _apiService.dio.post('/incident-rapports/notify-webhook/$incidentId');
    } catch (e) {
      throw Exception('Erreur génération rapport: $e');
    }
  }

  Future<void> deleteIncident(int id) async {
    final dio = ApiService().dio;
    final url = '/incidents/$id';
    final response = await dio.delete(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du signalement');
    }
  }
}
