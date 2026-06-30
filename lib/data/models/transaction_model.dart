class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String accountName;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.accountName,
    required this.createdAt,
  });
}

class BankAccountModel {
  final String id;
  final String name;
  final String bankName;
  final double balance;
  final String accountType;
  final DateTime createdAt;

  BankAccountModel({
    required this.id,
    required this.name,
    required this.bankName,
    required this.balance,
    required this.accountType,
    required this.createdAt,
  });
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}
