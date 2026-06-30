import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';

class ExpenseCategoryChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ExpenseCategoryChart({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = _calculateExpensesByCategory();

    if (expensesByCategory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No expenses to display',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    final colors = [
      AppColors.cyanNeon,
      AppColors.purpleNeon,
      AppColors.acidGreen,
      AppColors.errorRed,
      AppColors.orangeNeon,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor, width: 1),
        color: AppColors.bgSecondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(
                  expensesByCategory.length,
                  (index) {
                    final entry = expensesByCategory.entries.toList()[index];
                    final total = expensesByCategory.values
                        .fold(0.0, (sum, val) => sum + val);
                    final percentage = (entry.value / total) * 100;

                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: AppColors.deepSpaceDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildLegend(expensesByCategory, colors),
        ],
      ),
    );
  }

  Map<String, double> _calculateExpensesByCategory() {
    final Map<String, double> expenses = {};

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        expenses.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return expenses;
  }

  List<Widget> _buildLegend(
    Map<String, double> expensesByCategory,
    List<Color> colors,
  ) {
    return expensesByCategory.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final color = colors[index % colors.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(category),
            ),
            Text('\$$amount'),
          ],
        ),
      );
    }).toList();
  }
}
