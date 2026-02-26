import '../models/MonthlySummaryModel.dart';
import '../services/worker_service.dart';
import '../models/PresenceHistoryModel.dart';

class WorkerRepository {
  final WorkerService workerService;
  WorkerRepository({required this.workerService});

  Future<MonthlySummaryModel> getMonthlySummary(int workerId) {
    return workerService.fetchMonthlySummary(workerId);
  }

  Future<String> checkInOut(int workerId, {String? qrCodeText, double? latitude, double? longitude}) {
    return workerService.checkInOut(workerId, qrCodeText: qrCodeText, latitude: latitude, longitude: longitude);
  }

  Future<PresenceHistoryModel> getPresenceHistory({
    required int workerId,
    String? date, // date est optionnelle
  }) {
    return workerService.fetchPresenceHistory(workerId, date);
  }
}
