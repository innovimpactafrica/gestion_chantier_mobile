import 'package:gestion_chantier/bet/services/StudyService.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';

class BetStudyRepository {
  // Récupérer la liste des études pour un BET
  Future<BetStudiesResponseModel> getBetStudies({
    required int betId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print(
        '🔄 [BetStudyRepository] Récupération des études pour BET ID: $betId',
      );

      final data = await BetStudyService.fetchBetStudies(
        betId: betId,
        page: page,
        size: size,
      );
      final studiesResponse = BetStudiesResponseModel.fromJson(data);

      print('✅ [BetStudyRepository] Études récupérées avec succès');
      print('📊 [BetStudyRepository] Total: ${studiesResponse.totalElements}');
      print(
        '📊 [BetStudyRepository] Page actuelle: ${studiesResponse.number + 1}/${studiesResponse.totalPages}',
      );
      print(
        '📊 [BetStudyRepository] Études dans cette page: ${studiesResponse.content.length}',
      );

      return studiesResponse;
    } catch (e) {
      print(
        '❌ [BetStudyRepository] Erreur lors de la récupération des études: $e',
      );
      rethrow;
    }
  }
}


