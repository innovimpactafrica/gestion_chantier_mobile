part of 'studies_kpi_bloc.dart';

abstract class StudiesKpiState {}

class StudiesKpiInitial extends StudiesKpiState {}

class StudiesKpiLoading extends StudiesKpiState {}

class StudiesKpiLoaded extends StudiesKpiState {
  final StudyKpiModel model;
  StudiesKpiLoaded(this.model);
}

class StudiesKpiError extends StudiesKpiState {
  final String message;
  StudiesKpiError(this.message);
}
