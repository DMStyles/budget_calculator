import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/budget_provider.dart';
import '../screens/add_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Housing':
        return Icons.home_rounded;
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Utilities':
        return Icons.power_rounded;
      case 'Entertainment':
        return Icons.movie_creation_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Saving':
        return Icons.savings_rounded;
      case 'Salary':
        return Icons.work_rounded;
      case 'Freelance':
        return Icons.computer_rounded;
      case 'Investments':
        return Icons.trending_up_rounded;
      case 'Gifts':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Housing':
        return Colors.amber.shade300;
      case 'Food':
        return Colors.teal.shade300;
      case 'Transport':
        return Colors.blue.shade300;
      case 'Utilities':
        return Colors.purple.shade300;
      case 'Entertainment':
        return Colors.pink.shade300;
      case 'Shopping':
        return Colors.orange.shade300;
      case 'Saving':
        return Colors.greenAccent.shade400;
      case 'Salary':
        return Colors.green.shade400;
      case 'Freelance':
        return Colors.indigo.shade300;
      case 'Investments':
        return Colors.cyan.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final list = provider.transactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = isDark ? const Color(0xFF1E2025) : const Color(0xFFEEF0F6);
    final outlineColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: theme.colorScheme.onSurface.withOpacity(0.2),
              ),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        final TransactionModel tx = list[index];

        return Dismissible(
          key: Key(tx.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
            ),
            child: Icon(Icons.delete_sweep_rounded, color: theme.colorScheme.error),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                title: const Text('Delete Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text('Are you sure you want to delete this transaction?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            if (tx.id != null) {
              provider.deleteTransaction(tx.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${tx.title}" deleted'),
                  backgroundColor: surfaceColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outlineColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              leading: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _getCategoryColor(tx.category).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(tx.category),
                  color: _getCategoryColor(tx.category),
                  size: 24,
                ),
              ),
              title: Text(
                tx.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(tx.date),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.isIncome ? '+' : '-'} Rs. ${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: tx.isIncome ? theme.colorScheme.tertiary : theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    tx.category,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(transaction: tx),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
