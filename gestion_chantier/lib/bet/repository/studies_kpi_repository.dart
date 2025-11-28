import 'package:gestion_chantier/bet/services/StudyKpiService.dart';
import 'package:gestion_chantier/bet/models/StudyKpiModel.dart';

class BetStudiesKpiRepository {
  // Récupérer les KPIs des études pour un BET
  Future<BetStudyKpiModel> getBetStudyKpis(int betId) async {
    try {
      print(
        '🔄 [BetStudiesKpiRepository] Récupération des KPIs pour BET ID: $betId',
      );

      final data = await BetStudyKpiService.fetchBetStudyKpis(betId);
      final kpiModel = BetStudyKpiModel.fromJson(data);

      print('✅ [BetStudiesKpiRepository] KPIs récupérés avec succès');
      print('📊 [BetStudiesKpiRepository] Total: ${kpiModel.total}');

      return kpiModel;
    } catch (e) {
      print(
        '❌ [BetStudiesKpiRepository] Erreur lors de la récupération des KPIs: $e',
      );
      rethrow;
    }
  }
}


