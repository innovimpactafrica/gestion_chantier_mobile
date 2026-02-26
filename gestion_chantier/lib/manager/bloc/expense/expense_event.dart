import 'dart:io';

abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {
  final int budgetId;

  LoadExpenses({required this.budgetId});
}

class LoadMoreExpenses extends ExpenseEvent {
  final int budgetId;

  LoadMoreExpenses({required this.budgetId});
}

class AddExpense extends ExpenseEvent {
  final String description;
  final String date;
  final double amount;
  final int budgetId;
  final File? evidence;

  AddExpense({
    required this.description,
    required this.date,
    required this.amount,
    required this.budgetId,
    this.evidence,
  });
}

class DeleteExpense extends ExpenseEvent {
  final int expenseId;
  final int budgetId;

  DeleteExpense({
    required this.expenseId,
    required this.budgetId,
  });
}
