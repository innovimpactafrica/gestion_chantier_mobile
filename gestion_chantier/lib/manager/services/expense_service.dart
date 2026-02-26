import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gestion_chantier/manager/services/api_service.dart';

class ExpenseService {
  final ApiService _apiService = ApiService();

  /// CREATE EXPENSE (multipart/form-data)
  Future<Response> createExpense({
    required String description,
    required String date, // format MM-DD-YYYY
    required double amount,
    required int budgetId,
    File? evidence,
  }) async {
    FormData formData = FormData.fromMap({
      "description": description,
      "date": date,
      "amount": amount,
      "budgetId": budgetId,
      if (evidence != null)
        "evidence": await MultipartFile.fromFile(
          evidence.path,
          filename: evidence.path.split('/').last,
        ),
    });

    return await _apiService.dio.post(
      "/expenses",
      data: formData,
    );
  }

  /// DELETE EXPENSE
  Future<void> deleteExpense(int expenseId) async {
    await _apiService.dio.delete(
      "/expenses/$expenseId",
    );
  }

  /// GET EXPENSES BY BUDGET (pagination)
  Future<Response> getExpensesByBudget({
    required int budgetId,
    required int page,
    required int size,
  }) async {
    print(   "/expenses/budget/$budgetId",);
    return await _apiService.dio.get(
      "/expenses/budget/$budgetId",
      queryParameters: {
        "page": page,
        "size": size,
      },
    );
  }
}
