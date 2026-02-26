import 'dart:io';
import 'package:gestion_chantier/manager/models/expense_model.dart';
import 'package:gestion_chantier/manager/services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service = ExpenseService();

  Future<List<ExpenseModel>> fetchExpenses({
    required int budgetId,
    required int page,
    required int size,
  }) async {
    final response = await _service.getExpensesByBudget(
      budgetId: budgetId,
      page: page,
      size: size,
    );
  print(response.data['content']);
    final List data = response.data['content'];
    return data.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  Future<void> addExpense({
    required String description,
    required String date,
    required double amount,
    required int budgetId,
    File? evidence,
  }) async {
    await _service.createExpense(
      description: description,
      date: date,
      amount: amount,
      budgetId: budgetId,
      evidence: evidence,
    );
  }

  Future<void> removeExpense(int expenseId) async {
    await _service.deleteExpense(expenseId);
  }
}
