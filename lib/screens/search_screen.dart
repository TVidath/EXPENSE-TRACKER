import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/search_service.dart';
import 'package:expense_tracker/expenses_list.dart';
import 'package:expense_tracker/incomes_list.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> incomes;
  final Function(Expense) onRemoveExpense;
  final Function(Income) onRemoveIncome;

  const SearchScreen({
    super.key,
    required this.expenses,
    required this.incomes,
    required this.onRemoveExpense,
    required this.onRemoveIncome,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  List<Expense> _filteredExpenses = [];
  List<Income> _filteredIncomes = [];

  Category? _selectedCategory;
  IncomeSource? _selectedSource;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  bool _isAdvancedSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredExpenses = widget.expenses;
    _filteredIncomes = widget.incomes;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAdvancedSearch() {
    setState(() {
      _isAdvancedSearchVisible = !_isAdvancedSearchVisible;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSource = null;
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _searchController.clear();
      _filteredExpenses = widget.expenses;
      _filteredIncomes = widget.incomes;
    });
  }

  void _performSearch() {
    final searchQuery = _searchController.text;

    setState(() {
      _filteredExpenses = SearchService.advancedSearchExpenses(
        expenses: widget.expenses,
        titleQuery: searchQuery,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      );

      _filteredIncomes = SearchService.advancedSearchIncomes(
        incomes: widget.incomes,
        titleQuery: searchQuery,
        source: _selectedSource,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      );
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Expenses'), Tab(text: 'Incomes')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _toggleAdvancedSearch,
                icon: Icon(
                  _isAdvancedSearchVisible
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                label: Text(
                  _isAdvancedSearchVisible ? 'Hide Filters' : 'Show Filters',
                ),
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Reset'),
              ),
            ],
          ),
          if (_isAdvancedSearchVisible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            _tabController.index == 0
                                ? DropdownButtonFormField<Category?>(
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedCategory,
                                  items: [
                                    const DropdownMenuItem<Category?>(
                                      value: null,
                                      child: Text('All Categories'),
                                    ),
                                    ...Category.values
                                        .map(
                                          (category) =>
                                              DropdownMenuItem<Category>(
                                                value: category,
                                                child: Text(
                                                  category.name.toUpperCase(),
                                                ),
                                              ),
                                        )
                                        ,
                                  ],
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                    });
                                  },
                                )
                                : DropdownButtonFormField<IncomeSource?>(
                                  decoration: const InputDecoration(
                                    labelText: 'Source',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedSource,
                                  items: [
                                    const DropdownMenuItem<IncomeSource?>(
                                      value: null,
                                      child: Text('All Sources'),
                                    ),
                                    ...IncomeSource.values
                                        .map(
                                          (source) =>
                                              DropdownMenuItem<IncomeSource>(
                                                value: source,
                                                child: Text(
                                                  source.name.toUpperCase(),
                                                ),
                                              ),
                                        )
                                        ,
                                  ],
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedSource = newValue;
                                    });
                                  },
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Min Amount',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _minAmount = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Max Amount',
                            border: OutlineInputBorder(),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _maxAmount = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate == null
                                  ? 'Select Date'
                                  : DateFormat.yMd().format(_startDate!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate == null
                                  ? 'Select Date'
                                  : DateFormat.yMd().format(_endDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Expenses tab
                _filteredExpenses.isEmpty
                    ? const Center(child: Text('No expenses found'))
                    : ExpensesList(
                      expenses: _filteredExpenses,
                      onRemoveExpense: widget.onRemoveExpense,
                    ),
                // Incomes tab
                _filteredIncomes.isEmpty
                    ? const Center(child: Text('No incomes found'))
                    : IncomesList(
                      incomes: _filteredIncomes,
                      onRemoveIncome: widget.onRemoveIncome,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
