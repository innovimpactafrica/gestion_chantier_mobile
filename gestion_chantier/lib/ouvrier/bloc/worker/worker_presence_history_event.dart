import 'package:equatable/equatable.dart';

// Classe de base des événements
abstract class WorkerPresenceHistoryEvent extends Equatable {
  const WorkerPresenceHistoryEvent();

  @override
  List<Object?> get props => [];
}

// Événement pour charger l'historique de présence
class LoadWorkerPresenceHistoryEvent extends WorkerPresenceHistoryEvent {
  final int workerId;
  final String? date;  // La date est maintenant optionnelle

  const LoadWorkerPresenceHistoryEvent({
    required this.workerId,
    this.date, // La date est optionnelle
  });

  @override
  List<Object?> get props => [workerId, date];
}
