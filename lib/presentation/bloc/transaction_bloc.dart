import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';
import 'package:rocket_finance/data/repositories/transaction_repository.dart';

// Events
abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class LoadCurrentMonthTransactions extends TransactionEvent {}

class LoadTransactionsByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;
  LoadTransactionsByDateRange(this.startDate, this.endDate);
}

class AddTransaction extends TransactionEvent {
  final String title;
  final double amount;
  final String type;
  final String category;
  final String accountName;

  AddTransaction({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.accountName,
  });
}

class DeleteTransaction extends TransactionEvent {
  final String id;
  DeleteTransaction(this.id);
}

class LoadExpensesByCategory extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;
  LoadExpensesByCategory(this.startDate, this.endDate);
}

class LoadDailyTotals extends TransactionEvent {
  final DateTime date;
  LoadDailyTotals(this.date);
}

class LoadMonthlyTotals extends TransactionEvent {
  final DateTime month;
  LoadMonthlyTotals(this.month);
}

// States
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpenses;

  TransactionsLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
  });
}

class ExpensesByCategory extends TransactionState {
  final Map<String, double> categoryExpenses;
  ExpensesByCategory(this.categoryExpenses);
}

class DailyTotals extends TransactionState {
  final double income;
  final double expenses;
  DailyTotals(this.income, this.expenses);
}

class MonthlyTotals extends TransactionState {
  final double income;
  final double expenses;
  MonthlyTotals(this.income, this.expenses);
}

class TransactionSuccess extends TransactionState {
  final String message;
  TransactionSuccess(this.message);
}

class TransactionError extends TransactionState {
  final String error;
  TransactionError(this.error);
}

// Bloc
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadCurrentMonthTransactions>(_onLoadCurrentMonthTransactions);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<LoadExpensesByCategory>(_onLoadExpensesByCategory);
    on<LoadDailyTotals>(_onLoadDailyTotals);
    on<LoadMonthlyTotals>(_onLoadMonthlyTotals);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await _repository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onLoadCurrentMonthTransactions(
    LoadCurrentMonthTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await _repository.getCurrentMonthTransactions();
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final income = await _repository.getTotalIncomeByRange(firstDay, lastDay);
      final expenses = await _repository.getTotalExpensesByRange(firstDay, lastDay);
      emit(TransactionsLoaded(
        transactions: transactions,
        totalIncome: income,
        totalExpenses: expenses,
      ));
    } catch (e) {
      emit(TransactionError('Failed to load current month transactions: $e'));
    }
  }

  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await _repository.getTransactionsByDateRange(
        event.startDate,
        event.endDate,
      );
      final income = await _repository.getTotalIncomeByRange(event.startDate, event.endDate);
      final expenses = await _repository.getTotalExpensesByRange(event.startDate, event.endDate);
      emit(TransactionsLoaded(
        transactions: transactions,
        totalIncome: income,
        totalExpenses: expenses,
      ));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.createTransaction(
        title: event.title,
        amount: event.amount,
        type: event.type,
        category: event.category,
        accountName: event.accountName,
        createdAt: DateTime.now(),
      );
      emit(TransactionSuccess('Transaction added successfully'));
      add(LoadCurrentMonthTransactions());
    } catch (e) {
      emit(TransactionError('Failed to add transaction: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.id);
      emit(TransactionSuccess('Transaction deleted successfully'));
      add(LoadCurrentMonthTransactions());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: $e'));
    }
  }

  Future<void> _onLoadExpensesByCategory(
    LoadExpensesByCategory event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final expenses = await _repository.getExpensesByCategory(
        event.startDate,
        event.endDate,
      );
      emit(ExpensesByCategory(expenses));
    } catch (e) {
      emit(TransactionError('Failed to load expenses by category: $e'));
    }
  }

  Future<void> _onLoadDailyTotals(
    LoadDailyTotals event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final startOfDay = DateTime(event.date.year, event.date.month, event.date.day);
      final endOfDay = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        23,
        59,
        59,
      );
      final income = await _repository.getTotalIncomeByRange(startOfDay, endOfDay);
      final expenses = await _repository.getTotalExpensesByRange(startOfDay, endOfDay);
      emit(DailyTotals(income, expenses));
    } catch (e) {
      emit(TransactionError('Failed to load daily totals: $e'));
    }
  }

  Future<void> _onLoadMonthlyTotals(
    LoadMonthlyTotals event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final firstDay = DateTime(event.month.year, event.month.month, 1);
      final lastDay = DateTime(event.month.year, event.month.month + 1, 0);
      final income = await _repository.getTotalIncomeByRange(firstDay, lastDay);
      final expenses = await _repository.getTotalExpensesByRange(firstDay, lastDay);
      emit(MonthlyTotals(income, expenses));
    } catch (e) {
      emit(TransactionError('Failed to load monthly totals: $e'));
    }
  }
}
