import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class LocalDataSource {
  static Database? _database;
  static const String _dbName = 'rocket_finance.db';
  static const String _transactionsTable = 'transactions';
  static const String _bankAccountsTable = 'bank_accounts';
  static const String _categoriesTable = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        accountName TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Bank Accounts table
    await db.execute('''
      CREATE TABLE $_bankAccountsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        bankName TEXT NOT NULL,
        balance REAL NOT NULL,
        accountType TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // Transaction Operations
  Future<void> insertTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required String accountName,
    required DateTime createdAt,
  }) async {
    final db = await database;
    const uuid = Uuid();
    await db.insert(
      _transactionsTable,
      {
        'id': uuid.v4(),
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'accountName': accountName,
        'createdAt': createdAt.toIso8601String(),
      },
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(_transactionsTable);
    return result.map((map) => _mapToTransaction(map)).toList();
  }

  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDay, lastDay);
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      _transactionsTable,
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return result.map((map) => _mapToTransaction(map)).toList();
  }

  Future<double> getTotalIncomeByRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_transactionsTable WHERE type = ? AND createdAt BETWEEN ? AND ?',
      ['income', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final total = result.first['total'] as num?;
    return total?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpensesByRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_transactionsTable WHERE type = ? AND createdAt BETWEEN ? AND ?',
      ['expense', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final total = result.first['total'] as num?;
    return total?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM $_transactionsTable WHERE type = ? AND createdAt BETWEEN ? AND ? GROUP BY category',
      ['expense', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final Map<String, double> categoryMap = {};
    for (final row in result) {
      categoryMap[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return categoryMap;
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  TransactionModel _mapToTransaction(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      category: map['category'] as String,
      accountName: map['accountName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}