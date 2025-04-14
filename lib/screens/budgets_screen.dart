import 'package:flutter/material.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/widgets/add_budget.dart';
import 'package:expense_tracker/widgets/budget_list.dart';

class BudgetsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const BudgetsScreen({super.key, required this.expenses});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<Budget> _budgets = [];
  bool _isLoading = true;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Budget> loadedBudgets;
      if (_selectedCategory != null) {
        loadedBudgets = await BudgetService.getBudgetsByCategory(
          _selectedCategory!,
        );
      } else {
        loadedBudgets = await BudgetService.loadBudgets();
      }

      setState(() {
        _budgets = loadedBudgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading budgets: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openAddBudgetOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddBudget(onAddBudget: _addBudget);
      },
    );
  }

  Future<void> _addBudget(Budget budget) async {
    try {
      await BudgetService.addBudget(budget);
      await _loadBudgets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeBudget(Budget budget) async {
    try {
      await BudgetService.deleteBudget(budget.id);
      await _loadBudgets();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterBudgetsByCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No budgets found. Start adding some!'),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_budgets.isNotEmpty) {
      content = BudgetList(
        budgets: _budgets,
        expenses: widget.expenses,
        onRemoveBudget: _removeBudget,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            onPressed: _openAddBudgetOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by category: '),
                const SizedBox(width: 8),
                DropdownButton<Category?>(
                  value: _selectedCategory,
                  hint: const Text('All Categories'),
                  items: [
                    const DropdownMenuItem<Category?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...Category.values
                        .map(
                          (category) => DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          ),
                        )
                        ,
                  ],
                  onChanged: _filterBudgetsByCategory,
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
