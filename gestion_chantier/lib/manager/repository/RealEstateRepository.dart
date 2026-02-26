import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/services/RStateService.dart';

import '../../ouvrier/services/api_service.dart';
import '../models/PropertyType.dart';

class RealEstateRepository {
  final RStateService _apiService = RStateService();

  Future<void> createRealEstate({
    required int promoterId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required double area,
    required double price,
    required int propertyTypeId,
    required DateTime startDate,
    required DateTime endDate,
    File? planImage,

    // options bool
    bool hasGym = false,
    bool hasElevator = false,
    bool hasGarden = false,
    bool hasSwimmingPool = false,
    bool hasSharedTerrace = false,
    bool hasHall = true,
    bool hasPlayground = false,
    bool hasBicycleStorage = false,
    bool hasStorageRooms = false,
    bool mezzanine = false,
    bool hasSecurityService = false,
    bool hasWasteDisposalArea = false,
    bool hasLaundryRoom = false,
    bool hasParking = false,

    // autres champs
    int numberOfLots = 1,
    int? managerId,
    int? moaId,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'promoterId': promoterId,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'area': area,
        'price': price,
        'propertyTypeId': propertyTypeId,
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),

        'hasGym': hasGym,
        'hasElevator': hasElevator,
        'hasGarden': hasGarden,
        'hasSwimmingPool': hasSwimmingPool,
        'hasSharedTerrace': hasSharedTerrace,
        'hasHall': hasHall,
        'hasPlayground': hasPlayground,
        'hasBicycleStorage': hasBicycleStorage,
        'hasStorageRooms': hasStorageRooms,
        'mezzanine': mezzanine,
        'hasSecurityService': hasSecurityService,
        'hasWasteDisposalArea': hasWasteDisposalArea,
        'hasLaundryRoom': hasLaundryRoom,
        'hasParking': hasParking,

        'numberOfLots': numberOfLots,
        'managerId': managerId ?? 0,
        'moaId': moaId ?? 0,
        'description': description ?? '',

        if (planImage != null)
          'plan': await MultipartFile.fromFile(
            planImage.path,
            filename: planImage.path.split('/').last,
          ),
      });

      await _apiService.postMultipart('/realestate/save', formData);
    } catch (e) {
      throw Exception("Erreur lors de la création du bien : $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.year}";
  }


  /// GET PROPERTY TYPES
  Future<List<PropertyType>> getPropertyTypes() async {
    try {
      final response = await _apiService.get('/property-types/all');

      return (response as List).map((e) => PropertyType.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur chargement types de biens $e");
    }
  }

}
