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
        return Colors.amber;
      case 'Food':
        return Colors.teal;
      case 'Transport':
        return Colors.blue;
      case 'Utilities':
        return Colors.purple;
      case 'Entertainment':
        return Colors.pink;
      case 'Shopping':
        return Colors.orange;
      case 'Salary':
        return Colors.green;
      case 'Freelance':
        return Colors.indigo;
      case 'Investments':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final list = provider.transactions;

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
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 12),
              Text(
                'No transactions yet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
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
              color: Colors.red.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Delete Transaction', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Are you sure you want to delete this transaction?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
                  backgroundColor: Colors.grey.shade900,
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.03),
              ),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(tx.date),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
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
                      color: tx.isIncome ? Colors.tealAccent.shade400 : Colors.redAccent.shade200,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    tx.category,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
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
