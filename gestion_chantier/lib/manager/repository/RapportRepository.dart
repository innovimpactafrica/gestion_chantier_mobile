import 'dart:io';

import '../models/RapportModel.dart';
import '../services/rapportService_.dart';


class RapportRepository {
  final RapportService _service = RapportService();

  Future<List<RapportModel>> fetchRapports(int userId, {int page = 0, int size = 10}) {
    return _service.getRapports(userId, page: page, size: size);
  }

  Future<RapportModel> createRapport({
    required String titre,
    required String description,
    required int propertyId,
    required File file,
  }) {
    return _service.addRapport(
      titre: titre,
      description: description,
      propertyId: propertyId,
      file: file,
    );
  }

  Future<void> removeRapport(int id) {
    return _service.deleteRapport(id);
  }
}
