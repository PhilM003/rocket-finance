import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:rocket_finance/core/utils/excel_export_helper.dart';
import 'package:rocket_finance/presentation/bloc/transaction_bloc.dart';
import 'package:rocket_finance/presentation/widgets/transaction_list_tile.dart';
import 'package:rocket_finance/presentation/widgets/expense_category_chart.dart';
import 'package:share_plus/share_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<TransactionBloc>().add(LoadCurrentMonthTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTransactions() {
    if (_selectedDate != null) {
      final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
      context.read<TransactionBloc>().add(LoadTransactionsByDateRange(startOfDay, endOfDay));
    } else {
      context.read<TransactionBloc>().add(LoadCurrentMonthTransactions());
    }
  }

  Future<void> _exportTransactions() async {
    final bloc = context.read<TransactionBloc>();
    final state = bloc.state;

    if (state is TransactionsLoaded) {
      final csvContent = ExcelExportHelper.exportToCsv(state.transactions);
      final filename = ExcelExportHelper.generateFilename();
      
      await Share.shareWithResult(
        csvContent,
        subject: 'Rocket Finance Transactions Export',
        text: 'Exported transactions from Rocket Finance',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final dateFormatter = DateFormat('MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rocket Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportTransactions,
            tooltip: 'Export Transactions',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyanNeon),
            );
          }

          if (state is TransactionsLoaded) {
            final balance = state.totalIncome - state.totalExpenses;
            var transactions = state.transactions;
            transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Filter by search
            if (_searchController.text.isNotEmpty) {
              transactions = transactions
                  .where((t) => t.title.toLowerCase().contains(_searchController.text.toLowerCase()))
                  .toList();
            }

            // Filter by category
            if (_selectedCategory != null) {
              transactions = transactions.where((t) => t.category == _selectedCategory).toList();
            }

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
                    _buildSearchAndFilterBar(),
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
                        'Recent Transactions (${transactions.length})',
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
                            'No transactions found. Launch your first transaction! 🚀',
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
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return TransactionListTile(
                            transaction: transaction,
                            onEdit: () => _editTransaction(transaction),
                            onDelete: () => _deleteTransaction(transaction.id),
                          );
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

  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search, color: AppColors.cyanNeon),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                    _filterTransactions();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dividerColor),
                    color: AppColors.bgSecondary,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.cyanNeon, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null ? DateFormat('MMM dd').format(_selectedDate!) : 'Pick Date',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = null);
                  _filterTransactions();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorRed),
                    color: AppColors.bgSecondary,
                  ),
                  child: const Icon(Icons.close, color: AppColors.errorRed, size: 18),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _editTransaction(dynamic transaction) {
    Navigator.pushNamed(
      context,
      '/edit-transaction',
      arguments: transaction,
    );
  }

  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(DeleteTransaction(id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
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
