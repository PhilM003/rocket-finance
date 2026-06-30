import 'package:rocket_finance/data/database/app_database.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

class BankAccountRepository {
  final AppDatabase _database;

  BankAccountRepository(this._database);

  Future<List<BankAccountModel>> getAllBankAccounts() async {
    final accounts = await _database.getAllBankAccounts();
    return accounts.map((a) => BankAccountModel(
      id: a.id,
      name: a.name,
      bankName: a.bankName,
      balance: a.balance,
      accountType: a.accountType,
      createdAt: a.createdAt,
    )).toList();
  }

  Future<BankAccountModel?> getBankAccountById(String id) async {
    final account = await _database.getBankAccountById(id);
    return account != null
        ? BankAccountModel(
            id: account.id,
            name: account.name,
            bankName: account.bankName,
            balance: account.balance,
            accountType: account.accountType,
            createdAt: account.createdAt,
          )
        : null;
  }

  Future<void> createBankAccount({
    required String name,
    required String bankName,
    required String accountType,
  }) async {
    const uuid = Uuid();
    await _database.insertBankAccount(BankAccountsCompanion(
      id: Value(uuid.v4()),
      name: Value(name),
      bankName: Value(bankName),
      balance: const Value(0),
      accountType: Value(accountType),
      createdAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateBalance(String accountId, double newBalance) =>
      _database.updateBankAccountBalance(accountId, newBalance);

  Future<double> getTotalBalance() async {
    final accounts = await getAllBankAccounts();
    return accounts.fold(0, (sum, acc) => sum + acc.balance);
  }
}
