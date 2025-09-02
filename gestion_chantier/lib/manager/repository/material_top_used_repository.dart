import 'package:gestion_chantier/manager/models/MaterialTopUsedModel.dart';
import 'package:gestion_chantier/manager/services/MaterialsService.dart';

class MaterialTopUsedRepository {
  final MaterialsService _service = MaterialsService();

  Future<List<MaterialTopUsedModel>> fetchTopUsedMaterials(int propertyId) {
    return _service.fetchTopUsedMaterials(propertyId);
  }
}
