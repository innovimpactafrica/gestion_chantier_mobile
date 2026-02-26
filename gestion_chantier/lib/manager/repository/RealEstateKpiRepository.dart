import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/models/RealEstateKpiStatusModel.dart';

import '../../ouvrier/services/api_service.dart';

class RealEstateKpiRepository {
  final ApiService _apiService = ApiService();

  Future<bool> checkCanCreateProject(int id) async {
    try {
      final response = await _apiService.dio.get(
        '/subscriptions/can-create-project/$id',
      );

      // response.data contient true ou false
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is String) {
        // au cas où l'API renvoie "true" ou "false" en string
        return response.data.toLowerCase() == 'true';
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  Future<RealEstateKpiStatusModel> getStatusKpiByPromoter(
    int promoterId,
  ) async {
    try {
      print('Récupération KPI status pour le promoteur: $promoterId');

      final response = await _apiService.dio.get(
        '/realestate/kpi/status',
        queryParameters: {'promoterId': promoterId},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('KPI response status: ${response.statusCode}');
      print('KPI response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return RealEstateKpiStatusModel.fromJson(response.data);
      }

      throw Exception('Erreur serveur: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException KPI');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('URL: ${e.requestOptions.uri}');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ Exception générale KPI: $e');
      print(stackTrace);
      throw Exception('Erreur inattendue: $e');
    }
  }
}
