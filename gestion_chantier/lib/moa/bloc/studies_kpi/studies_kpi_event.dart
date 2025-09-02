part of 'studies_kpi_bloc.dart';

abstract class StudiesKpiEvent {}

class LoadStudiesKpi extends StudiesKpiEvent {
  final int? promoterId;
  LoadStudiesKpi({this.promoterId});
}
