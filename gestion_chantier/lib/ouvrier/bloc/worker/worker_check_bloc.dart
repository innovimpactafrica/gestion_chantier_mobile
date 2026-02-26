import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_check_event.dart';
import 'worker_check_state.dart';
import '../../repository/worker_repository.dart';

class WorkerCheckBloc extends Bloc<WorkerCheckEvent, WorkerCheckState> {
  final WorkerRepository repository;
  bool isEntry = true;
  String? lastEntry;
  String? lastExit;
  WorkerCheckBloc({required this.repository}) : super(WorkerCheckInitial()) {
    on<DoWorkerCheckEvent>(_onCheck);
  }

  Future<void> _onCheck(
    DoWorkerCheckEvent event,
    Emitter<WorkerCheckState> emit,
  ) async {
    emit(WorkerCheckLoading());
    try {
      final time = await repository.checkInOut(
        event.workerId,
        qrCodeText: event.qrCodeText,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      if (isEntry) {
        lastEntry = time;
      } else {
        lastExit = time;
      }
      emit(WorkerCheckSuccess(time: time, isEntry: isEntry));
      isEntry = !isEntry;
    } on DioError catch (e) {
      String errorMsg = 'Erreur lors du pointage';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMsg = e.response?.data['message'] ?? errorMsg;
        } else if (e.response?.data is String) {
          errorMsg = e.response?.data;
        }
      } else if (e.type == DioErrorType.connectionTimeout) {
        errorMsg = 'Timeout de la requête';
      } else if (e.type == DioErrorType.unknown) {
        errorMsg = 'Problème de connexion réseau';
      }

      emit(WorkerCheckError(errorMsg ));
    }
  }
}
