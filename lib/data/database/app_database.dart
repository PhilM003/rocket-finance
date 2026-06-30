import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get accountName => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BankAccount')
class BankAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get accountType => text().withDefault(const Constant('checking'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Transactions, BankAccounts, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(transactions)
          ..where((t) => t.createdAt.isBetweenValues(startDate, endDate)))
        .get();
  }

  Future<List<Transaction>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(firstDay, lastDay);
  }

  Future<double> getTotalIncomeByRange(DateTime start, DateTime end) async {
    final txns = await getTransactionsByDateRange(start, end);
    return txns.where((t) => t.type == 'income').fold<double>(0, (sum, t) => sum + t.amount);
  }

  Future<double> getTotalExpensesByRange(DateTime start, DateTime end) async {
    final txns = await getTransactionsByDateRange(start, end);
    return txns.where((t) => t.type == 'expense').fold<double>(0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final txns = await getTransactionsByDateRange(start, end);
    final expenses = txns.where((t) => t.type == 'expense').toList();
    final Map<String, double> totals = {};
    for (var t in expenses) {
      totals.update(t.category, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return totals;
  }

  Future<void> insertTransaction(TransactionsCompanion txn) => into(transactions).insert(txn);

  Future<bool> updateTransaction(Transaction txn) => update(transactions).replace(txn);

  Future<int> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<List<BankAccount>> getAllBankAccounts() => select(bankAccounts).get();

  Future<BankAccount?> getBankAccountById(String id) =>
      (select(bankAccounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> insertBankAccount(BankAccountsCompanion account) =>
      into(bankAccounts).insert(account);

  Future<bool> updateBankAccountBalance(String id, double newBalance) async {
    final account = await getBankAccountById(id);
    if (account != null) {
      return update(bankAccounts).replace(account.copyWith(balance: newBalance));
    }
    return false;
  }

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();

  Future<void> seedDefaultCategories() async {
    final defaults = [
      CategoriesCompanion(
        id: const Value('1'),
        name: const Value('Salary'),
        icon: const Value('💰'),
        type: const Value('income'),
      ),
      CategoriesCompanion(
        id: const Value('2'),
        name: const Value('Food'),
        icon: const Value('🍔'),
        type: const Value('expense'),
      ),
      CategoriesCompanion(
        id: const Value('3'),
        name: const Value('Rent'),
        icon: const Value('🏠'),
        type: const Value('expense'),
      ),
      CategoriesCompanion(
        id: const Value('4'),
        name: const Value('Utilities'),
        icon: const Value('⚡'),
        type: const Value('expense'),
      ),
      CategoriesCompanion(
        id: const Value('5'),
        name: const Value('Snacks'),
        icon: const Value('🍿'),
        type: const Value('expense'),
      ),
      CategoriesCompanion(
        id: const Value('6'),
        name: const Value('Others'),
        icon: const Value('📦'),
        type: const Value('expense'),
      ),
    ];
    for (var cat in defaults) {
      try {
        await into(categories).insert(cat);
      } catch (_) {}
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'rocket_finance',
    web: DriftWebDatabase.inMemory(),
    mobile: LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'rocket_finance.db'));
      return NativeDatabase.createBackgroundConnection(file);
    }),
  );
}
