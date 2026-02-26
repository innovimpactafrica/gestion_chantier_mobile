import 'package:gestion_chantier/manager/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final bool hasReachedMax;
  final int currentPage;

  ExpenseLoaded({
    required this.expenses,
    required this.hasReachedMax,
    required this.currentPage,
  });

  ExpenseLoaded copyWith({
    List<ExpenseModel>? expenses,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError(this.message);
}
