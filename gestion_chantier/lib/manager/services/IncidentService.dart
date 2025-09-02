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
    required int propertyId,
    required List<File> pictures,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'propertyId': propertyId,
      'pictures': [
        for (final file in pictures)
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
      ],
    });

    final response = await _apiService.dio.post(
      '/incidents/save',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout du signalement');
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
