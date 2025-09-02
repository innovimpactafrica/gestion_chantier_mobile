import 'package:gestion_chantier/moa/models/BudgetModel.dart';

abstract class BudgetState {}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetDashboardLoaded extends BudgetState {
  final Map<String, dynamic> dashboardData;
  BudgetDashboardLoaded(this.dashboardData);
}

class BudgetPropertyLoaded extends BudgetState {
  final BudgetModel budget;
  BudgetPropertyLoaded(this.budget);
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);
}
