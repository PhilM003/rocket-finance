import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:rocket_finance/data/models/transaction_model.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListTile({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final dateFormatter = DateFormat('MMM d, y');
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? AppColors.acidGreen : AppColors.errorRed;
    final amountPrefix = isIncome ? '+' : '-';
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor, width: 1),
        color: AppColors.bgSecondary,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amountColor.withOpacity(0.2),
            ),
            child: Icon(icon, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormatter.format(transaction.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$amountPrefix\$${formatter.format(transaction.amount)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
