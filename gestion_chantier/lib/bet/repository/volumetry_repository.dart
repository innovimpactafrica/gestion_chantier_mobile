import 'package:gestion_chantier/bet/services/VolumetryService.dart';
import 'package:gestion_chantier/bet/models/VolumetryModel.dart';

class BetVolumetryRepository {
  // Récupérer la volumétrie pour un BET
  Future<BetVolumetryModel> getBetVolumetry(int betId) async {
    try {
      print(
        '🔄 [BetVolumetryRepository] Récupération de la volumétrie pour BET ID: $betId',
      );

      final data = await BetVolumetryService.fetchBetVolumetry(betId);
      final volumetryModel = BetVolumetryModel.fromJson(data);

      print('✅ [BetVolumetryRepository] Volumétrie récupérée avec succès');
      print(
        '📊 [BetVolumetryRepository] Total études: ${volumetryModel.totalStudyRequests}',
      );
      print(
        '📊 [BetVolumetryRepository] Propriétés distinctes: ${volumetryModel.distinctPropertiesCount}',
      );
      print(
        '📊 [BetVolumetryRepository] Total rapports: ${volumetryModel.totalReports}',
      );

      return volumetryModel;
    } catch (e) {
      print(
        '❌ [BetVolumetryRepository] Erreur lors de la récupération de la volumétrie: $e',
      );
      rethrow;
    }
  }
}


