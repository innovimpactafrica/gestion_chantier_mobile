import 'package:gestion_chantier/moa/services/MaterialsService.dart';

class MaterialKpiRepository {
  final MaterialsService _service = MaterialsService();

  Future<Map<String, double>> fetchUnitDistribution(int propertyId) {
    return _service.getUnitDistributionByProperty(propertyId);
  }
}
