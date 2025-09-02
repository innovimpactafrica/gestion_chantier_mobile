import 'package:gestion_chantier/moa/services/CommandesService.dart';
import 'package:gestion_chantier/moa/models/DeliveryModel.dart';

class DeliveryRepository {
  final CommandeService _service = CommandeService();

  Future<List<DeliveryModel>> fetchDeliveries(
    int propertyId, {
    int page = 0,
    int size = 10,
  }) {
    return _service.fetchDeliveries(propertyId, page: page, size: size);
  }
}
