import 'package:gestion_chantier/manager/models/material_monthly_stat.dart';
import 'package:gestion_chantier/manager/services/MaterialsService.dart';

class MaterialMonthlyStatsRepository {
  final MaterialsService _service = MaterialsService();

  Future<List<MaterialMonthlyStat>> fetchMonthlyStats(int propertyId) {
    return _service.getMonthlyStats(propertyId);
  }
}
