import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/budget_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _title = tx?.title ?? '';
    _amount = tx?.amount ?? 0.0;
    _selectedDate = tx?.date ?? DateTime.now();
    _isIncome = tx?.isIncome ?? false;

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    _selectedCategory = tx?.category ??
        (_isIncome
            ? provider.incomeCategories.first
            : provider.expenseCategories.first);
  }

  void _presentDatePicker() {
    final theme = Theme.of(context);
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final tx = TransactionModel(
      id: widget.transaction?.id,
      title: _title,
      amount: _amount,
      date: _selectedDate,
      category: _selectedCategory,
      isIncome: _isIncome,
    );

    if (widget.transaction == null) {
      provider.addTransaction(tx);
    } else {
      provider.updateTransaction(tx);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final categories = _isIncome ? provider.incomeCategories : provider.expenseCategories;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputFillColor = isDark ? const Color(0xFF1E2025) : const Color(0xFFEEF0F6);
    final inputBorderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Income/Expense
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: inputBorderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = false;
                            _selectedCategory = provider.expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: !_isIncome ? theme.colorScheme.secondary.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: !_isIncome ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = true;
                            _selectedCategory = provider.incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _isIncome ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: _isIncome ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                initialValue: _title,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  filled: true,
                  fillColor: inputFillColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                onSaved: (val) => _title = val!.trim(),
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                initialValue: _amount > 0 ? _amount.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Amount (LKR)',
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  filled: true,
                  fillColor: inputFillColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Please enter a valid amount';
                  return null;
                },
                onSaved: (val) => _amount = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Date Selector
              GestureDetector(
                onTap: _presentDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: inputBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
                      ),
                      Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Categories Header
              Text(
                'Category',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Choice Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final chipColor = _isIncome ? theme.colorScheme.primary : theme.colorScheme.secondary;

                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: chipColor,
                    backgroundColor: inputFillColor,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : inputBorderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIncome ? theme.colorScheme.primary : theme.colorScheme.secondary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    widget.transaction == null ? 'Save Transaction' : 'Update Transaction',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
