import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:rocket_finance/presentation/bloc/transaction_bloc.dart';
import 'package:rocket_finance/presentation/widgets/transaction_list_tile.dart';
import 'package:rocket_finance/presentation/widgets/expense_category_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadCurrentMonthTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final dateFormatter = DateFormat('MMMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Rocket Finance')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyanNeon),
            );
          }

          if (state is TransactionsLoaded) {
            final balance = state.totalIncome - state.totalExpenses;
            final transactions = state.transactions;
            transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(formatter, balance),
                    const SizedBox(height: 24),
                    _buildIncomeExpenseSummary(
                      formatter,
                      state.totalIncome,
                      state.totalExpenses,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Month: ${dateFormatter.format(DateTime.now())}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (transactions.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Expenses by Category',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: AppColors.purpleNeon),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ExpenseCategoryChart(transactions: transactions),
                          const SizedBox(height: 24),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Recent Transactions',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: AppColors.cyanNeon),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No transactions yet. Launch your first transaction! 🚀',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.take(10).length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return TransactionListTile(transaction: transaction);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cyanNeon,
        foregroundColor: AppColors.deepSpaceDark,
        onPressed: () {
          Navigator.of(context).pushNamed('/add-transaction');
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceCard(NumberFormat formatter, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyanNeon, width: 2),
        color: AppColors.bgSecondary,
        boxShadow: [
          BoxShadow(
            color: AppColors.cyanNeon.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${formatter.format(balance)}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: balance >= 0 ? AppColors.acidGreen : AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSummary(
    NumberFormat formatter,
    double totalIncome,
    double totalExpenses,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Income',
            '\$${formatter.format(totalIncome)}',
            AppColors.acidGreen,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Expenses',
            '\$${formatter.format(totalExpenses)}',
            AppColors.errorRed,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color accentColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor, width: 1.5),
        color: AppColors.bgSecondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
