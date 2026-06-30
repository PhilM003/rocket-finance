import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rocket_finance/core/theme/app_theme.dart';
import 'package:rocket_finance/data/datasources/local_datasource.dart';
import 'package:rocket_finance/data/repositories/transaction_repository.dart';
import 'package:rocket_finance/data/repositories/bank_account_repository.dart';
import 'package:rocket_finance/presentation/bloc/transaction_bloc.dart';
import 'package:rocket_finance/presentation/screens/dashboard_screen.dart';
import 'package:rocket_finance/presentation/screens/add_transaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RocketFinanceApp());
}

class RocketFinanceApp extends StatelessWidget {
  const RocketFinanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localDataSource = LocalDataSource();
    final transactionRepository = TransactionRepository(localDataSource);
    final bankAccountRepository = BankAccountRepository(localDataSource);

    return MaterialApp(
      title: 'Rocket Finance',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TransactionRepository>(
            create: (context) => transactionRepository,
          ),
          RepositoryProvider<BankAccountRepository>(
            create: (context) => bankAccountRepository,
          ),
        ],
        child: BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            transactionRepository: context.read<TransactionRepository>(),
          ),
          child: const DashboardScreen(),
        ),
      ),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
      },
    );
  }
}
