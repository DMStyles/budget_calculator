import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';

class BudgetProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  // Predefined default categories
  List<String> _expenseCategories = [
    'Housing',
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Saving',
    'Other'
  ];

  List<String> _incomeCategories = [
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
    'Saving': 1000.0,
    'Other': 100.0,
  };

  ThemeMode _themeMode = ThemeMode.system;

  BudgetProvider() {
    _loadThemeFromPrefs();
    _loadCategoriesFromPrefs();
    _loadCategoryBudgetsFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt('theme_mode');
      if (modeIndex != null) {
        _themeMode = ThemeMode.values[modeIndex];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme from prefs: $e');
    }
  }

  Future<void> _loadCategoriesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exp = prefs.getStringList('expense_categories');
      if (exp != null) {
        _expenseCategories = exp;
      }
      final inc = prefs.getStringList('income_categories');
      if (inc != null) {
        _incomeCategories = inc;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _saveCategoriesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('expense_categories', _expenseCategories);
      await prefs.setStringList('income_categories', _incomeCategories);
    } catch (e) {
      debugPrint('Error saving categories: $e');
    }
  }

  Future<void> _loadCategoryBudgetsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('category_budgets');
      if (jsonStr != null) {
        final Map<String, dynamic> decoded = json.decode(jsonStr);
        decoded.forEach((key, val) {
          _categoryBudgets[key] = (val as num).toDouble();
        });
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading category budgets: $e');
    }
  }

  Future<void> _saveCategoryBudgetsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('category_budgets', json.encode(_categoryBudgets));
    } catch (e) {
      debugPrint('Error saving category budgets: $e');
    }
  }

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  Map<String, double> get categoryBudgets => _categoryBudgets;
  ThemeMode get themeMode => _themeMode;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get incomeCategories => _incomeCategories;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
    } catch (e) {
      debugPrint('Error saving theme to prefs: $e');
    }
  }

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
    _categoryBudgets[category] = amount;
    _saveCategoryBudgetsToPrefs();
    notifyListeners();
  }

  // Add a new custom category
  Future<void> addCategory(String name, bool isIncome) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    if (isIncome) {
      if (_incomeCategories.contains(cleanName)) return;
      _incomeCategories.add(cleanName);
    } else {
      if (_expenseCategories.contains(cleanName)) return;
      _expenseCategories.add(cleanName);
      _categoryBudgets[cleanName] = 500.0; // Default limit for custom expense category
      await _saveCategoryBudgetsToPrefs();
    }
    await _saveCategoriesToPrefs();
    notifyListeners();
  }

  // Rename an existing category
  Future<void> renameCategory(String oldName, String newName, bool isIncome) async {
    final cleanNewName = newName.trim();
    if (cleanNewName.isEmpty || oldName == cleanNewName) return;

    if (isIncome) {
      final index = _incomeCategories.indexOf(oldName);
      if (index == -1 || _incomeCategories.contains(cleanNewName)) return;
      _incomeCategories[index] = cleanNewName;
    } else {
      final index = _expenseCategories.indexOf(oldName);
      if (index == -1 || _expenseCategories.contains(cleanNewName)) return;
      _expenseCategories[index] = cleanNewName;

      // Update budgets map key
      if (_categoryBudgets.containsKey(oldName)) {
        final limit = _categoryBudgets[oldName]!;
        _categoryBudgets.remove(oldName);
        _categoryBudgets[cleanNewName] = limit;
        await _saveCategoryBudgetsToPrefs();
      }
    }

    // Update matching transactions in SQLite database
    await DatabaseHelper.instance.updateTransactionCategory(oldName, cleanNewName, isIncome);

    // Sync in-memory transaction list state
    await fetchTransactions();
    await _saveCategoriesToPrefs();
  }

  // Delete an existing category and safely recategorize existing transactions to 'Other'
  Future<void> deleteCategory(String name, bool isIncome) async {
    if (name == 'Other') return; // Cannot delete fallback category

    bool removed = false;
    if (isIncome) {
      removed = _incomeCategories.remove(name);
    } else {
      removed = _expenseCategories.remove(name);
      _categoryBudgets.remove(name);
      await _saveCategoryBudgetsToPrefs();
    }

    if (removed) {
      // Recategorize all transactions belonging to deleted category to 'Other' fallback category
      await DatabaseHelper.instance.updateTransactionCategory(name, 'Other', isIncome);

      // Sync transactions list state
      await fetchTransactions();
      await _saveCategoriesToPrefs();
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
