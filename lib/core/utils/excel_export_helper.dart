import 'package:intl/intl.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';

class ExcelExportHelper {
  static const String _csvHeader = 'Date,Title,Category,Type,Amount,Account\n';

  /// Export transactions to CSV format
  static String exportToCsv(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _csvHeader;
    }

    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final numberFormatter = NumberFormat('#,##0.00', 'en_US');

    final buffer = StringBuffer(_csvHeader);

    for (final transaction in transactions) {
      final date = dateFormatter.format(transaction.createdAt);
      final title = _escapeCsvField(transaction.title);
      final category = _escapeCsvField(transaction.category);
      final type = transaction.type.toUpperCase();
      final amount = numberFormatter.format(transaction.amount);
      final account = _escapeCsvField(transaction.accountName);

      buffer.writeln('$date,$title,$category,$type,$amount,$account');
    }

    return buffer.toString();
  }

  /// Export transactions summary to CSV format
  static String exportSummaryToCsv(List<TransactionModel> transactions) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final numberFormatter = NumberFormat('#,##0.00', 'en_US');

    double totalIncome = 0;
    double totalExpenses = 0;
    final categoryExpenses = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
        categoryExpenses.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('Financial Summary Report');
    buffer.writeln('Generated: ${dateFormatter.format(DateTime.now())}\n');
    buffer.writeln('Total Income,${numberFormatter.format(totalIncome)}');
    buffer.writeln('Total Expenses,${numberFormatter.format(totalExpenses)}');
    buffer.writeln('Net Balance,${numberFormatter.format(totalIncome - totalExpenses)}\n');
    buffer.writeln('Expenses by Category');

    for (final entry in categoryExpenses.entries) {
      buffer.writeln('${entry.key},${numberFormatter.format(entry.value)}');
    }

    return buffer.toString();
  }

  /// Escape CSV field values
  static String _escapeCsvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Generate filename for export
  static String generateFilename({bool summary = false}) {
    final dateFormatter = DateFormat('yyyy-MM-dd_HHmmss');
    final timestamp = dateFormatter.format(DateTime.now());
    final suffix = summary ? '_summary' : '';
    return 'transactions$suffix\_$timestamp.csv';
  }
}
