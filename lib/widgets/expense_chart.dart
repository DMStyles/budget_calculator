import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class ExpenseChart extends StatefulWidget {
  const ExpenseChart({super.key});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int touchedIndex = -1;

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
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final distribution = provider.getCategoryExpensesDistribution();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E2025) : const Color(0xFFEEF0F6);
    final borderCol = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    if (distribution.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          children: [
            Text(
              'Expense Breakdown',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses recorded yet',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final totalExp = provider.totalExpenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Expense Breakdown',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: distribution.entries.map((entry) {
                  final idx = distribution.keys.toList().indexOf(entry.key);
                  final isTouched = idx == touchedIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 35.0 : 25.0;
                  final percentage = (entry.value / totalExp) * 100;

                  return PieChartSectionData(
                    color: categoryColors[entry.key] ?? Colors.grey,
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: distribution.keys.map((cat) {
              final spent = distribution[cat] ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColors[cat] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$cat (Rs. ${spent.toStringAsFixed(0)})',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
