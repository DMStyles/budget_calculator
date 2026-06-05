import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, bool isIncome) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Add ${isIncome ? 'Income' : 'Expense'} Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Category name',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              provider.addCategory(controller.text, isIncome);
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addCategory(controller.text, isIncome);
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryListTab(isIncome: false, isDark: isDark),
          _CategoryListTab(isIncome: true, isDark: isDark),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isIncome = _tabController.index == 1;
          return FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, isIncome),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: Text('Add ${isIncome ? 'Income' : 'Expense'}'),
          );
        },
      ),
    );
  }
}

class _CategoryListTab extends StatelessWidget {
  final bool isIncome;
  final bool isDark;

  const _CategoryListTab({required this.isIncome, required this.isDark});

  void _showRenameDialog(BuildContext context, BudgetProvider provider, String oldName) {
    final controller = TextEditingController(text: oldName);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Rename Category'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'New category name',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _renameCategory(ctx, provider, oldName, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _renameCategory(ctx, provider, oldName, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _renameCategory(
      BuildContext ctx, BudgetProvider provider, String oldName, String newName) {
    if (newName.trim().isNotEmpty && newName.trim() != oldName) {
      provider.renameCategory(oldName, newName, isIncome);
      Navigator.of(ctx).pop();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Renamed "$oldName" to "$newName"'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      Navigator.of(ctx).pop();
    }
  }

  void _confirmDeleteCategory(BuildContext context, BudgetProvider provider, String name) {
    if (name == 'Other') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('"Other" is a required fallback category and cannot be deleted.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent.shade200),
            const SizedBox(width: 10),
            const Text('Delete Category'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"$name"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    '?\n\nAll existing transactions in this category will be moved to "Other".',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteCategory(name, isIncome);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "$name" and moved its transactions to "Other"'),
                  backgroundColor: Colors.redAccent.shade200,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final categories = isIncome ? provider.incomeCategories : provider.expenseCategories;
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = isDark ? const Color(0xFF1E2025) : const Color(0xFFF0F4F9);

    return Column(
      children: [
        Expanded(
          child: categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No categories yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: categories.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isProtected = category == 'Other';
                    return _CategoryTile(
                      name: category,
                      isProtected: isProtected,
                      isIncome: isIncome,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      colorScheme: colorScheme,
                      onRename: () => _showRenameDialog(context, provider, category),
                      onDelete: () => _confirmDeleteCategory(context, provider, category),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final bool isProtected;
  final bool isIncome;
  final bool isDark;
  final Color surfaceColor;
  final ColorScheme colorScheme;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.name,
    required this.isProtected,
    required this.isIncome,
    required this.isDark,
    required this.surfaceColor,
    required this.colorScheme,
    required this.onRename,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'housing': return Icons.home_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'utilities': return Icons.bolt_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'saving': return Icons.savings_rounded;
      case 'salary': return Icons.work_rounded;
      case 'freelance': return Icons.laptop_mac_rounded;
      case 'investments': return Icons.trending_up_rounded;
      case 'gifts': return Icons.card_giftcard_rounded;
      default: return isIncome ? Icons.attach_money_rounded : Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isIncome
                ? colorScheme.tertiary.withValues(alpha: 0.15)
                : colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _getCategoryIcon(name),
            size: 20,
            color: isIncome ? colorScheme.tertiary : colorScheme.primary,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: isProtected
            ? const Text('Built-in (cannot be deleted)', style: TextStyle(fontSize: 11, color: Colors.grey))
            : null,
        trailing: isProtected
            ? Tooltip(
                message: 'Rename',
                child: IconButton(
                  icon: Icon(Icons.edit_rounded, color: colorScheme.primary, size: 20),
                  onPressed: onRename,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Rename',
                    child: IconButton(
                      icon: Icon(Icons.edit_rounded, color: colorScheme.primary, size: 20),
                      onPressed: onRename,
                    ),
                  ),
                  Tooltip(
                    message: 'Delete',
                    child: IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent.shade200, size: 20),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

