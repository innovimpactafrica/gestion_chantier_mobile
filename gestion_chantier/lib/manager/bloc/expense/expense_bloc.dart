import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/expense/expense_state.dart';
import 'package:gestion_chantier/manager/repository/expense_repository.dart';

import 'expense_event.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;
  static const int pageSize = 10;

  ExpenseBloc(this.repository) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  /// First page
  Future<void> _onLoadExpenses(
      LoadExpenses event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(ExpenseLoading());

    try {
      final expenses = await repository.fetchExpenses(
        budgetId: event.budgetId,
        page: 0,
        size: pageSize,
      );
      print(  expenses );
      emit(
        ExpenseLoaded(
          expenses: expenses,
          hasReachedMax: expenses.length < pageSize,
          currentPage: 0,
        ),
      );
    } catch (e) {
      print(e.toString());
      emit(ExpenseError(e.toString()));
    }
  }

  /// Load next page (scroll)
  Future<void> _onLoadMoreExpenses(
      LoadMoreExpenses event,
      Emitter<ExpenseState> emit,
      ) async {
    if (state is! ExpenseLoaded) return;

    final currentState = state as ExpenseLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final nextPage = currentState.currentPage + 1;

      final newExpenses = await repository.fetchExpenses(
        budgetId: event.budgetId,
        page: nextPage,
        size: pageSize,
      );



      emit(
        currentState.copyWith(
          expenses: List.of(currentState.expenses)..addAll(newExpenses),
          currentPage: nextPage,
          hasReachedMax: newExpenses.length < pageSize,
        ),
      );
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  /// Add expense then refresh
  Future<void> _onAddExpense(
      AddExpense event,
      Emitter<ExpenseState> emit,
      ) async {
    try {
      await repository.addExpense(
        description: event.description,
        date: event.date,
        amount: event.amount,
        budgetId: event.budgetId,
        evidence: event.evidence,
      );

      add(LoadExpenses(budgetId: event.budgetId));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  /// Delete expense then refresh
  Future<void> _onDeleteExpense(
      DeleteExpense event,
      Emitter<ExpenseState> emit,
      ) async {
    try {
      await repository.removeExpense(event.expenseId);
      add(LoadExpenses(budgetId: event.budgetId));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
