import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import 'api_service.dart';

/// Service de gestion du pointage pour les ouvriers
class PointageService {
  static final PointageService _instance = PointageService._internal();
  final ApiService _apiService = ApiService();

  factory PointageService() {
    return _instance;
  }

  PointageService._internal();

  /// Récupérer les adresses de pointage pour un projet
  Future<List<Map<String, dynamic>>> getAdressesPointage(int projectId) async {
    try {
      print(
        '🏢 [PointageService] Récupération des adresses pour le projet $projectId',
      );

      final response = await _apiService.dio.get(
        '/pointing-addresses/property/$projectId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> adresses = response.data;
        final List<Map<String, dynamic>> adressesList =
            adresses.map((adresse) {
              return Map<String, dynamic>.from(adresse);
            }).toList();

        print('✅ [PointageService] ${adressesList.length} adresses récupérées');
        return adressesList;
      } else {
        print(
          '❌ [PointageService] Erreur lors de la récupération des adresses: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print(
        '❌ [PointageService] Exception lors de la récupération des adresses: $e',
      );
      return [];
    }
  }

  /// Créer une nouvelle adresse de pointage
  Future<Map<String, dynamic>> creerAdressePointage({
    required double latitude,
    required double longitude,
    required String name,
    required String qrcode,
  }) async {
    try {
      print('🏗️ [PointageService] Création d\'une nouvelle adresse...');
      print('   📍 Latitude: $latitude');
      print('   📍 Longitude: $longitude');
      print('   📝 Nom: $name');
      print('   📱 QR Code: $qrcode');

      final response = await _apiService.dio.post(
        '/pointing-addresses',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'name': name,
          'qrcode': qrcode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> nouvelleAdresse = Map<String, dynamic>.from(
          response.data,
        );
        print(
          '✅ [PointageService] Adresse créée avec succès: ID ${nouvelleAdresse['id']}',
        );
        return {
          'success': true,
          'message': 'Adresse créée avec succès',
          'data': nouvelleAdresse,
        };
      } else {
        print(
          '❌ [PointageService] Erreur lors de la création: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Erreur lors de la création de l\'adresse',
        };
      }
    } catch (e) {
      print('❌ [PointageService] Exception lors de la création: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la création de l\'adresse: ${e.toString()}',
      };
    }
  }
}
