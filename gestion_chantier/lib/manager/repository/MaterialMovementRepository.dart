import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import '../services/api_service.dart';

class MaterialMovementRepository {
  final ApiService _apiService = ApiService();

  Future<List<MaterialMovementModel>> getMovementsByMaterial(
    int materialId,
    int page,
    int size,
  ) async {
    try {
      final response = await _apiService.dio.get(
        '/materials/$materialId/movements',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        final List data = response.data["content"];
        return data
            .map((json) => MaterialMovementModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  Future<void> addMovement({
    required int materialId,
    required double quantity,
    required MovementType type,
    String? comment,
  }) async {
    try {
      final data = {
        'materialId': materialId,
        'quantity': quantity,
        'type': type.name,
        'comment': comment,
      };

      final response = await _apiService.dio.post(
        '/materials/movements',
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Impossible de créer le mouvement');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  Future<void> deleteMovement(int movementId) async {
    try {
      final response = await _apiService.dio.delete(
        '/materials/movements/$movementId',
      );

    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
