import 'package:gestion_chantier/manager/services/MaterialsService.dart';

class MaterialKpiRepository {
  final MaterialsService _service = MaterialsService();

  Future<Map<String, double>> fetchUnitDistribution(int propertyId, {DateTime? startDate, DateTime? endDate}) {
    return _service.getUnitDistributionByProperty(propertyId, startDate: startDate, endDate: endDate);
  }
}
