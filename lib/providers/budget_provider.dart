import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class BudgetProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  // Predefined categories
  final List<String> expenseCategories = [
    'Housing',
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Other'
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Other'
  ];

  // Budget limits for each expense category (default limits)
  final Map<String, double> _categoryBudgets = {
    'Housing': 1000.0,
    'Food': 500.0,
    'Transport': 200.0,
    'Utilities': 300.0,
    'Entertainment': 150.0,
    'Shopping': 250.0,
    'Other': 100.0,
  };

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  Map<String, double> get categoryBudgets => _categoryBudgets;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DatabaseHelper.instance.getAllTransactions();
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await DatabaseHelper.instance.insertTransaction(transaction);
      final newTx = transaction.copyWith(id: id);
      _transactions.insert(0, newTx);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding transaction: $e");
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await DatabaseHelper.instance.updateTransaction(transaction);
      final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating transaction: $e");
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((tx) => tx.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    }
  }

  // Set new budget limit for a category
  void setCategoryBudget(String category, double amount) {
    if (_categoryBudgets.containsKey(category)) {
      _categoryBudgets[category] = amount;
      notifyListeners();
    }
  }

  // Getters for dashboard metrics
  double get totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get remainingBalance => totalIncome - totalExpenses;

  // Get total expense spent in a specific category
  double getExpenseSpentForCategory(String category) {
    return _transactions
        .where((tx) => !tx.isIncome && tx.category == category)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Get percentage of budget spent for a category
  double getBudgetUsagePercent(String category) {
    final limit = _categoryBudgets[category] ?? 0.0;
    if (limit == 0.0) return 0.0;
    return getExpenseSpentForCategory(category) / limit;
  }

  // Get Category distributions for the pie chart
  Map<String, double> getCategoryExpensesDistribution() {
    final Map<String, double> distribution = {};
    for (var cat in expenseCategories) {
      final spent = getExpenseSpentForCategory(cat);
      if (spent > 0) {
        distribution[cat] = spent;
      }
    }
    return distribution;
  }
}
