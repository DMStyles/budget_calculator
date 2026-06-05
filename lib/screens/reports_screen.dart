import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _selectedMonth;

  final Map<String, Color> categoryColors = {
    'Housing': Colors.amber.shade300,
    'Food': Colors.teal.shade300,
    'Transport': Colors.blue.shade300,
    'Utilities': Colors.purple.shade300,
    'Entertainment': Colors.pink.shade300,
    'Shopping': Colors.orange.shade300,
    'Saving': Colors.greenAccent.shade400,
    'Other': Colors.grey.shade400,
  };

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month) {
      return; // Can't go to future months
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter transactions for the selected month
    final monthlyTransactions = provider.transactions.where((tx) {
      return tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month;
    }).toList();

    // Calculations
    final monthlyIncome = monthlyTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final monthlyExpenses = monthlyTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final netSavings = monthlyIncome - monthlyExpenses;
    final savingsRate = monthlyIncome > 0 ? (netSavings / monthlyIncome) * 100 : 0.0;

    // Category breakdown
    final Map<String, double> categorySpent = {};
    for (var tx in monthlyTransactions.where((tx) => !tx.isIncome)) {
      categorySpent[tx.category] = (categorySpent[tx.category] ?? 0.0) + tx.amount;
    }

    // Sort category breakdown by amount spent descending
    final sortedCategories = categorySpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Daily Average Calculation
    final int daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final int elapsedDays = (_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month)
        ? DateTime.now().day
        : daysInMonth;
    final dailyAverage = monthlyExpenses / (elapsedDays > 0 ? elapsedDays : 1);

    // Dynamic Pixel UI Colors
    final surfaceColor = isDark ? const Color(0xFF1E2025) : const Color(0xFFF0F4F9);
    final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    size: 28,
                    color: (_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month)
                        ? Colors.grey
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Summary Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.45,
              children: [
                _buildSummaryCard('Earnings', monthlyIncome, Colors.tealAccent.shade400, surfaceColor, outlineColor),
                _buildSummaryCard('Spendings', monthlyExpenses, Colors.redAccent.shade200, surfaceColor, outlineColor),
                _buildSummaryCard(
                  'Net Saved',
                  netSavings,
                  netSavings >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                  surfaceColor,
                  outlineColor,
                ),
                _buildSummaryCard(
                  'Savings Rate',
                  savingsRate,
                  Colors.blueAccent.shade100,
                  surfaceColor,
                  outlineColor,
                  isPercent: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Visual Charts Section
            if (monthlyTransactions.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 72, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text(
                        'No transactions recorded this month.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              )
            ] else ...[
              // Comparative Chart / Breakdown
              _buildChartSection(monthlyIncome, monthlyExpenses, sortedCategories, surfaceColor, outlineColor),
              const SizedBox(height: 24),

              // Insights
              _buildInsightsSection(monthlyIncome, monthlyExpenses, sortedCategories, dailyAverage, elapsedDays, surfaceColor, outlineColor),
              const SizedBox(height: 24),

              // Category Breakdown list
              _buildCategoryList(sortedCategories, monthlyExpenses, surfaceColor, outlineColor),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color accentColor, Color cardBg, Color borderCol, {bool isPercent = false}) {
    final format = isPercent ? '${value.toStringAsFixed(1)}%' : 'Rs. ${value.toStringAsFixed(0)}';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              format,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(double income, double expenses, List<MapEntry<String, double>> categories, Color cardBg, Color borderCol) {
    final maxVal = income > expenses ? income : expenses;
    final double incomePercent = maxVal > 0 ? (income / maxVal) : 0.0;
    final double expensePercent = maxVal > 0 ? (expenses / maxVal) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Earning vs Spending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Earnings', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('Rs. ${income.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: incomePercent,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent.shade400),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spendings', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('Rs. ${expenses.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: expensePercent,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent.shade200),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    double income,
    double expenses,
    List<MapEntry<String, double>> categories,
    double dailyAverage,
    int elapsedDays,
    Color cardBg,
    Color borderCol,
  ) {
    String topCategory = 'None';
    double topCategoryAmt = 0.0;
    if (categories.isNotEmpty) {
      topCategory = categories.first.key;
      topCategoryAmt = categories.first.value;
    }

    final ratio = income > 0 ? (expenses / income) * 100 : 0.0;
    String ratioText = '';
    if (ratio == 0) {
      ratioText = 'No spending recorded yet!';
    } else if (ratio < 50) {
      ratioText = 'Healthy spending! You spent under 50% of your income.';
    } else if (ratio <= 85) {
      ratioText = 'Moderately balanced. Try targeting higher savings next month.';
    } else {
      ratioText = 'Caution: You spent over 85% of your earnings.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInsightRow(Icons.stars_rounded, Colors.amber.shade300, 'Top Category', '$topCategory (Rs. ${topCategoryAmt.toStringAsFixed(0)})'),
          const Divider(height: 24, color: Colors.white12),
          _buildInsightRow(Icons.calendar_view_day_rounded, Colors.blueAccent.shade100, 'Daily Average', 'Rs. ${dailyAverage.toStringAsFixed(0)} / day (over $elapsedDays days)'),
          const Divider(height: 24, color: Colors.white12),
          _buildInsightRow(Icons.psychology_rounded, Colors.purpleAccent.shade100, 'Spending Flow', ratioText),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, Color iconColor, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, double>> categories, double totalSpent, Color cardBg, Color borderCol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...categories.map((entry) {
            final double percent = totalSpent > 0 ? (entry.value / totalSpent) : 0.0;
            final catColor = categoryColors[entry.key] ?? Colors.grey;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Text(
                        'Rs. ${entry.value.toStringAsFixed(0)} (${(percent * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
