import 'package:rocket_finance/data/database/app_database.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

class TransactionRepository {
  final AppDatabase _database;

  TransactionRepository(this._database);

  Future<List<TransactionModel>> getAllTransactions() async {
    final txns = await _database.getAllTransactions();
    return txns.map((t) => TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      type: t.type,
      category: t.category,
      accountName: t.accountName,
      createdAt: t.createdAt,
    )).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final txns = await _database.getTransactionsByDateRange(startDate, endDate);
    return txns.map((t) => TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      type: t.type,
      category: t.category,
      accountName: t.accountName,
      createdAt: t.createdAt,
    )).toList();
  }

  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    final txns = await _database.getCurrentMonthTransactions();
    return txns.map((t) => TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      type: t.type,
      category: t.category,
      accountName: t.accountName,
      createdAt: t.createdAt,
    )).toList();
  }

  Future<double> getTotalIncomeByRange(DateTime start, DateTime end) =>
      _database.getTotalIncomeByRange(start, end);

  Future<double> getTotalExpensesByRange(DateTime start, DateTime end) =>
      _database.getTotalExpensesByRange(start, end);

  Future<Map<String, double>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  ) => _database.getExpensesByCategory(start, end);

  Future<void> createTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required String accountName,
    required DateTime createdAt,
  }) async {
    const uuid = Uuid();
    await _database.insertTransaction(TransactionsCompanion(
      id: Value(uuid.v4()),
      title: Value(title),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      accountName: Value(accountName),
      createdAt: Value(createdAt),
    ));
  }

  Future<void> deleteTransaction(String id) =>
      _database.deleteTransaction(id);
}
