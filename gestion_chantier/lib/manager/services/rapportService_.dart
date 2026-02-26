import 'package:dio/dio.dart';
import 'dart:io';
import '../models/RapportModel.dart';
import 'api_service.dart';

class RapportService {
  final ApiService _apiService = ApiService();

  // Lister les rapports d'un utilisateur
  Future<List<RapportModel>> getRapports(int id, {int page = 0, int size = 10}) async {
    final response = await _apiService.dio.get(
      '/rapports/$id',
      queryParameters: {"page": page, "size": size,},
    );

    return (response.data['content'] as List)
        .map((e) => RapportModel.fromJson(e))
        .toList();
  }

  // Ajouter un rapport
  Future<RapportModel> addRapport({
    required String titre,
    required String description,
    required int propertyId,
    required File file,
  }) async {
    FormData formData = FormData.fromMap({
      "titre": titre,
      "description": description,
      "propertyId": propertyId,
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });

    final response = await _apiService.dio.post('/rapports/save', data: formData);
    return RapportModel.fromJson(response.data);
  }

  // Supprimer un rapport
  Future<void> deleteRapport(int rapportId) async {
    await _apiService.dio.delete('/rapports/delete/$rapportId');
  }
}
