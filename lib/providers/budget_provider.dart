import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    checkForUpdates(); // Check for updates silently on startup
    _migrateAndFetch();
  }
  
  Future<void> _migrateAndFetch() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool('has_migrated_to_supabase') ?? false;
      
      if (!hasMigrated && Supabase.instance.client.auth.currentSession != null) {
        // Try migrating local data
        try {
          final localTxs = await DatabaseHelper.instance.getAllTransactions();
          if (localTxs.isNotEmpty) {
            final toInsert = localTxs.map((tx) => {
              'title': tx.title,
              'amount': tx.amount,
              'date': tx.date.toIso8601String(),
              'category': tx.category,
              'is_income': tx.isIncome,
            }).toList();
            
            await Supabase.instance.client.from('transactions').insert(toInsert);
          }
          await prefs.setBool('has_migrated_to_supabase', true);
        } catch (e) {
          debugPrint('Migration error: $e');
        }
      }
      
      await fetchTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    if (Supabase.instance.client.auth.currentSession == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .select()
          .order('date', ascending: false);
          
      _transactions = (response as List).map((json) {
        return TransactionModel(
          id: json['id'] as int,
          title: json['title'] as String,
          amount: (json['amount'] as num).toDouble(),
          date: DateTime.parse(json['date'] as String),
          category: json['category'] as String,
          isIncome: json['is_income'] as bool,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final response = await Supabase.instance.client
          .from('transactions')
          .insert({
            'title': transaction.title,
            'amount': transaction.amount,
            'date': transaction.date.toIso8601String(),
            'category': transaction.category,
            'is_income': transaction.isIncome,
          })
          .select()
          .single();
          
      final newTx = TransactionModel(
        id: response['id'] as int,
        title: response['title'] as String,
        amount: (response['amount'] as num).toDouble(),
        date: DateTime.parse(response['date'] as String),
        category: response['category'] as String,
        isIncome: response['is_income'] as bool,
      );
      _transactions.insert(0, newTx);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding transaction: $e");
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return;
    try {
      await Supabase.instance.client
          .from('transactions')
          .update({
            'title': transaction.title,
            'amount': transaction.amount,
            'date': transaction.date.toIso8601String(),
            'category': transaction.category,
            'is_income': transaction.isIncome,
          })
          .eq('id', transaction.id!);
          
      final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _transactions.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating transaction: $e");
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await Supabase.instance.client
          .from('transactions')
          .delete()
          .eq('id', id);
          
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

    // Update matching transactions in Supabase database
    try {
      await Supabase.instance.client
          .from('transactions')
          .update({'category': cleanNewName})
          .eq('category', oldName)
          .eq('is_income', isIncome);
    } catch (e) {
      debugPrint("Error renaming category in Supabase: $e");
    }

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
      // Recategorize all transactions belonging to deleted category to 'Other'
      try {
        await Supabase.instance.client
            .from('transactions')
            .update({'category': 'Other'})
            .eq('category', name)
            .eq('is_income', isIncome);
      } catch (e) {
        debugPrint("Error recategorizing in Supabase: $e");
      }

      // Sync transactions list state
      await fetchTransactions();
      await _saveCategoriesToPrefs();
    }
  }

  // Helper for current month transactions
  List<TransactionModel> get _currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) {
      return tx.date.month == now.month && tx.date.year == now.year;
    }).toList();
  }

  // Getters for dashboard metrics (Current Month Only)
  double get totalIncome {
    return _currentMonthTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpenses {
    return _currentMonthTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get remainingBalance => totalIncome - totalExpenses;

  // Get total expense spent in a specific category (Current Month Only)
  double getExpenseSpentForCategory(String category) {
    return _currentMonthTransactions
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

  // Update checking state
  bool _hasUpdate = false;
  String _latestVersion = '';
  String _updateUrl = '';
  String _updateNotes = '';
  bool _isCheckingUpdate = false;

  bool get hasUpdate => _hasUpdate;
  String get latestVersion => _latestVersion;
  String get updateUrl => _updateUrl;
  String get updateNotes => _updateNotes;
  bool get isCheckingUpdate => _isCheckingUpdate;

  Future<void> checkForUpdates() async {
    _isCheckingUpdate = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version.replaceAll(RegExp(r'[^\d.]'), '');

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/DMStyles/budget_calculator/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestTag = data['tag_name'] as String;
        final releaseNotes = data['body'] as String? ?? 'No release notes provided.';
        final releaseUrl = data['html_url'] as String;

        final remoteVersion = latestTag.replaceAll(RegExp(r'[^\d.]'), '');

        _hasUpdate = _isVersionNewer(localVersion, remoteVersion);
        _latestVersion = latestTag;
        _updateNotes = releaseNotes;
        _updateUrl = releaseUrl;
      }
    } catch (e) {
      debugPrint('Silent update check failed: $e');
    } finally {
      _isCheckingUpdate = false;
      notifyListeners();
    }
  }

  bool _isVersionNewer(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < latestParts.length; i++) {
      int currentVal = i < currentParts.length ? currentParts[i] : 0;
      int latestVal = latestParts[i];
      if (latestVal > currentVal) return true;
      if (latestVal < currentVal) return false;
    }
    return false;
  }

  // Export Data to CSV
  Future<void> exportData() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('ID,Title,Amount,Date,Category,IsIncome');
      for (var tx in _transactions) {
        // Escape quotes and commas in title
        final escapedTitle = tx.title.replaceAll('"', '""');
        buffer.writeln('${tx.id},"$escapedTitle",${tx.amount},${tx.date.toIso8601String()},"${tx.category}",${tx.isIncome}');
      }
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/budget_data_export.csv');
      await file.writeAsString(buffer.toString());
      
      await Share.shareXFiles([XFile(file.path)], subject: 'Budget Data Export');
    } catch (e) {
      debugPrint('Export failed: $e');
      rethrow;
    }
  }

  // Import Data from CSV
  Future<void> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        List<String> lines = contents.split('\n');
        
        if (lines.isEmpty) return;
        
        // Remove header if present
        if (lines.first.toLowerCase().startsWith('id')) {
          lines.removeAt(0);
        }

        int importedCount = 0;
        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          
          var regex = RegExp(r',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
          List<String> parts = line.split(regex);
          
          if (parts.length >= 6) {
            String title = parts[1].replaceAll('"', '').trim();
            double amount = double.tryParse(parts[2].trim()) ?? 0.0;
            DateTime? date = DateTime.tryParse(parts[3].trim());
            String category = parts[4].replaceAll('"', '').trim();
            bool isIncome = parts[5].trim().toLowerCase() == 'true';
            
            if (date != null && title.isNotEmpty) {
              // Insert into Supabase directly
              try {
                await Supabase.instance.client
                  .from('transactions')
                  .insert({
                    'title': title,
                    'amount': amount,
                    'date': date.toIso8601String(),
                    'category': category,
                    'is_income': isIncome,
                  });
                importedCount++;
              } catch (e) {
                debugPrint('Failed to import row: $e');
              }
            }
          }
        }
        
        if (importedCount > 0) {
          await fetchTransactions(); // Refresh UI
        }
      }
    } catch (e) {
      debugPrint('Import failed: $e');
      rethrow;
    }
  }
}
