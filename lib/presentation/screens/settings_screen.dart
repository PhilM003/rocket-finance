import 'package:flutter/material.dart';
import 'package:rocket_finance/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _incomeCategories;
  late TextEditingController _expenseCategories;
  bool _enableNotifications = true;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _incomeCategories = TextEditingController(text: 'Salary, Other');
    _expenseCategories = TextEditingController(text: 'Food, Rent, Utilities, Snacks, Other');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('notifications') ?? true;
      _currency = prefs.getString('currency') ?? 'USD';
      _incomeCategories.text = prefs.getString('incomeCategories') ?? 'Salary, Other';
      _expenseCategories.text = prefs.getString('expenseCategories') ?? 'Food, Rent, Utilities, Snacks, Other';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _enableNotifications);
    await prefs.setString('currency', _currency);
    await prefs.setString('incomeCategories', _incomeCategories.text);
    await prefs.setString('expenseCategories', _expenseCategories.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  void dispose() {
    _incomeCategories.dispose();
    _expenseCategories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('General Settings'),
              const SizedBox(height: 16),
              _buildDropdownSetting(
                label: 'Currency',
                value: _currency,
                items: ['USD', 'EUR', 'GBP', 'JPY', 'AUD'],
                onChanged: (value) {
                  setState(() => _currency = value!);
                },
              ),
              const SizedBox(height: 24),
              _buildSwitchSetting(
                label: 'Enable Notifications',
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() => _enableNotifications = value);
                },
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Categories'),
              const SizedBox(height: 16),
              Text('Income Categories', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _incomeCategories,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Separate with commas',
                  prefixIcon: Icon(Icons.trending_up, color: AppColors.cyanNeon),
                ),
              ),
              const SizedBox(height: 20),
              Text('Expense Categories', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _expenseCategories,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Separate with commas',
                  prefixIcon: Icon(Icons.trending_down, color: AppColors.cyanNeon),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('💾 Save Settings'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dividerColor),
                  color: AppColors.bgSecondary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Rocket Finance',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0\n\nA space-themed personal finance app built with Flutter.\n\n© 2026 Rocket Finance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.cyanNeon,
          ),
    );
  }

  Widget _buildDropdownSetting({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.settings, color: AppColors.cyanNeon),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.cyanNeon,
        ),
      ],
    );
  }
}
