abstract class BudgetEvent {}

class LoadBudgetDashboardKpi extends BudgetEvent {}

class LoadBudgetByProperty extends BudgetEvent {
  final int propertyId;
  LoadBudgetByProperty(this.propertyId);
}
