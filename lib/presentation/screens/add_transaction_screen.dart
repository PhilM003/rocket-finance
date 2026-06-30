import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:rocket_finance/presentation/bloc/transaction_bloc.dart';
import 'package:rocket_finance/presentation/widgets/blast_off_animation.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _accountController;

  String? _selectedType = 'expense';
  String? _selectedCategory = 'Others';
  late GlobalKey<BlastOffAnimationState> _blastOffKey;

  final List<String> _transactionTypes = ['Income', 'Expense'];
  final List<String> _expenseCategories = [
    'Food',
    'Rent',
    'Utilities',
    'Snacks',
    'Others',
  ];
  final List<String> _incomeCategories = ['Salary', 'Others'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _accountController = TextEditingController();
    _blastOffKey = GlobalKey<BlastOffAnimationState>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _handleSaveTransaction() {
    if (_validateForm()) {
      _blastOffKey.currentState?.animateBlastOff(() {
        _submitTransaction();
      });
    }
  }

  bool _validateForm() {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a title');
      return false;
    }
    if (_amountController.text.isEmpty) {
      _showError('Please enter an amount');
      return false;
    }
    if (double.tryParse(_amountController.text) == null) {
      _showError('Please enter a valid amount');
      return false;
    }
    if (_accountController.text.isEmpty) {
      _showError('Please select a bank account');
      return false;
    }
    return true;
  }

  void _submitTransaction() {
    final amount = double.parse(_amountController.text);
    final type = _selectedType == 'income' ? 'income' : 'expense';

    context.read<TransactionBloc>().add(
      AddTransaction(
        title: _titleController.text,
        amount: amount,
        type: type,
        category: _selectedCategory ?? 'Others',
        accountName: _accountController.text,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successGreen,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          } else if (state is TransactionError) {
            _showError(state.error);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlastOffAnimation(
                  key: _blastOffKey,
                  child: _buildInputForm(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSaveTransaction,
                    child: const Text('🚀 Launch Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyanNeon, width: 2),
        color: AppColors.bgSecondary,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: AppColors.cyanNeon),
          ),
          const SizedBox(height: 16),
          Text('Type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _buildTypeSelector(),
          const SizedBox(height: 16),
          Text('Title', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g., Grocery Shopping',
              prefixIcon: Icon(Icons.description, color: AppColors.cyanNeon),
            ),
          ),
          const SizedBox(height: 16),
          Text('Amount', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 16),
          Text('Category', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          Text('Bank Account / Vault', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _accountController,
            decoration: const InputDecoration(
              hintText: 'e.g., Checking Account',
              prefixIcon: Icon(Icons.account_balance, color: AppColors.cyanNeon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: _transactionTypes.map((type) {
        final isSelected = (_selectedType == 'income' && type == 'Income') ||
            (_selectedType == 'expense' && type == 'Expense');
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type.toLowerCase();
                _selectedCategory = _selectedType == 'income'
                    ? _incomeCategories.first
                    : _expenseCategories.first;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.cyanNeon : AppColors.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? AppColors.cyanNeon.withOpacity(0.2) : Colors.transparent,
              ),
              child: Text(
                type,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? AppColors.cyanNeon : AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _selectedType == 'income'
        ? _incomeCategories
        : _expenseCategories;
    final currentCategory = _selectedCategory ?? categories.first;

    return DropdownButtonFormField<String>(
      value: categories.contains(currentCategory) ? currentCategory : categories.first,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.category, color: AppColors.cyanNeon),
      ),
    );
  }
}
