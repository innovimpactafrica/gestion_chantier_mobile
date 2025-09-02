import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/budget/budget_event.dart';
import 'package:gestion_chantier/moa/bloc/budget/budget_state.dart';
import 'package:gestion_chantier/moa/services/budget_service.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetService _budgetService = BudgetService();

  BudgetBloc() : super(BudgetInitial()) {
    on<LoadBudgetDashboardKpi>(_onLoadBudgetDashboardKpi);
  }

  Future<void> _onLoadBudgetDashboardKpi(
    LoadBudgetDashboardKpi event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final dashboardData = await _budgetService.getBudgetDashboardKpi();
      if (dashboardData != null) {
        emit(BudgetDashboardLoaded(dashboardData));
      } else {
        emit(BudgetError('Aucune donnée de budget disponible'));
      }
    } catch (e) {
      emit(BudgetError('Erreur lors du chargement des données budget: $e'));
    }
  }
}
