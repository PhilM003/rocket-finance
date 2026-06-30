import 'package:rocket_finance/data/datasources/local_datasource.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';

class TransactionRepository {
  final LocalDataSource _localDataSource;

  TransactionRepository(this._localDataSource);

  Future<void> createTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required String accountName,
    required DateTime createdAt,
  }) async {
    await _localDataSource.insertTransaction(
      title: title,
      amount: amount,
      type: type,
      category: category,
      accountName: accountName,
      createdAt: createdAt,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    return await _localDataSource.getAllTransactions();
  }

  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    return await _localDataSource.getCurrentMonthTransactions();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _localDataSource.getTransactionsByDateRange(startDate, endDate);
  }

  Future<double> getTotalIncomeByRange(DateTime startDate, DateTime endDate) async {
    return await _localDataSource.getTotalIncomeByRange(startDate, endDate);
  }

  Future<double> getTotalExpensesByRange(DateTime startDate, DateTime endDate) async {
    return await _localDataSource.getTotalExpensesByRange(startDate, endDate);
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _localDataSource.getExpensesByCategory(startDate, endDate);
  }

  Future<void> deleteTransaction(String id) async {
    await _localDataSource.deleteTransaction(id);
  }
}