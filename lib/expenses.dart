import 'package:expense_tracker/addexpenses.dart';
import 'package:expense_tracker/addincome.dart';
import 'package:expense_tracker/expenses_list.dart';
import 'package:expense_tracker/incomes_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/screens/budgets_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';
import 'package:expense_tracker/screens/search_screen.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/services/data_persistence.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses>
    with SingleTickerProviderStateMixin {
  List<Expense> _registeredExpenses = [];
  List<Income> _registeredIncomes = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Animation controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeSettings();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeSettings() async {
    // Load settings when the app starts
    await SettingsService.loadSettings();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final expenses = await DataPersistence.loadExpenses();
    final incomes = await DataPersistence.loadIncomes();

    setState(() {
      _registeredExpenses = expenses;
      _registeredIncomes = incomes;
      _isLoading = false;
    });

    // Animate when data is loaded
    _animationController.reset();
    _animationController.forward();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddExpense(onAddExpense: _addExpense);
      },
    );
  }

  void _openAddIncomeOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddIncome(onAddIncome: _addIncome);
      },
    );
  }

  void _addExpense(Expense expense) async {
    setState(() {
      _registeredExpenses.add(expense);
    });
    await DataPersistence.saveExpenses(_registeredExpenses);
  }

  void _addIncome(Income income) async {
    setState(() {
      _registeredIncomes.add(income);
    });
    await DataPersistence.saveIncomes(_registeredIncomes);
  }

  void _removeExpense(Expense expense) async {
    setState(() {
      _registeredExpenses.remove(expense);
    });
    await DataPersistence.saveExpenses(_registeredExpenses);
  }

  void _removeIncome(Income income) async {
    setState(() {
      _registeredIncomes.remove(income);
    });
    await DataPersistence.saveIncomes(_registeredIncomes);
  }

  double get _totalExpenses {
    return _registeredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get _totalIncome {
    return _registeredIncomes.fold(0, (sum, income) => sum + income.amount);
  }

  double get _balance {
    return _totalIncome - _totalExpenses;
  }

  Map<Category, double> get _expensesByCategory {
    final map = <Category, double>{};
    for (final expense in _registeredExpenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  // Current month's expenses
  double get _currentMonthExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _registeredExpenses
        .where((expense) =>
            expense.date
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(endOfMonth.add(const Duration(days: 1))))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Current month's income
  double get _currentMonthIncome {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _registeredIncomes
        .where((income) =>
            income.date
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            income.date.isBefore(endOfMonth.add(const Duration(days: 1))))
        .fold(0, (sum, income) => sum + income.amount);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToBudgetsScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BudgetsScreen(expenses: _registeredExpenses),
          ),
        )
        .then((_) => _loadData()); // Refresh data when returning
  }

  void _navigateToReportsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportsScreen(
          expenses: _registeredExpenses,
          incomes: _registeredIncomes,
        ),
      ),
    );
  }

  void _navigateToSearchScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          expenses: _registeredExpenses,
          incomes: _registeredIncomes,
          onRemoveExpense: _removeExpense,
          onRemoveIncome: _removeIncome,
        ),
      ),
    );
  }

  void _navigateToSettingsScreen() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        )
        .then((_) => setState(() {})); // Refresh UI when returning
  }

  void _navigateToProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  Color _getBalanceColor() {
    return _balance >= 0
        ? const Color(0xFF4CAF50) // Green for positive
        : const Color(0xFFF44336); // Red for negative
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Create staggered animations
    final fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Create sequenced animations for the cards
    final balanceCardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    final monthlyCardsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    final categoriesAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    final listViewsAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );

    Widget content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  EdgeInsets.all(isSmallScreen ? 8 : 16), // Adaptive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card with Animation
                  FadeTransition(
                    opacity: balanceCardAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(balanceCardAnimation),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                              isSmallScreen ? 12 : 16), // Adaptive padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isSmallScreen
                                      ? 12
                                      : 14, // Adaptive font size
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                SettingsService.formatCurrency(_balance),
                                style: TextStyle(
                                  fontSize: isSmallScreen
                                      ? 24
                                      : 28, // Adaptive font size
                                  fontWeight: FontWeight.bold,
                                  color: _getBalanceColor(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem(
                                    'Income',
                                    _totalIncome,
                                    Icons.arrow_upward,
                                    Colors.green,
                                    isSmallScreen,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.grey[300],
                                  ),
                                  _buildSummaryItem(
                                    'Expenses',
                                    _totalExpenses,
                                    Icons.arrow_downward,
                                    Colors.red,
                                    isSmallScreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24), // Adaptive spacing

                  // Monthly Overview Title
                  FadeTransition(
                    opacity: monthlyCardsAnimation,
                    child: Text(
                      'Monthly Overview: $currentMonth',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18, // Adaptive font size
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Monthly Summary Cards
                  FadeTransition(
                    opacity: monthlyCardsAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(monthlyCardsAnimation),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMonthlyCard(
                              'Income',
                              _currentMonthIncome,
                              Icons.trending_up,
                              const Color(0xFF4CAF50),
                              isSmallScreen,
                            ),
                          ),
                          SizedBox(
                              width:
                                  isSmallScreen ? 8 : 16), // Adaptive spacing
                          Expanded(
                            child: _buildMonthlyCard(
                              'Expenses',
                              _currentMonthExpenses,
                              Icons.trending_down,
                              const Color(0xFFF44336),
                              isSmallScreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24), // Adaptive spacing

                  // Top Categories - Only show if there are expenses
                  if (_expensesByCategory.isNotEmpty) ...[
                    FadeTransition(
                      opacity: categoriesAnimation,
                      child: Text(
                        'Top Expense Categories',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 16 : 18, // Adaptive font size
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categories Grid - Adaptive sizing based on screen width
                    FadeTransition(
                      opacity: categoriesAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(categoriesAnimation),
                        child: LayoutBuilder(builder: (context, constraints) {
                          // Determine number of columns based on available width
                          final crossAxisCount = screenSize.width < 600 ? 2 : 3;
                          return GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing:
                                isSmallScreen ? 8 : 10, // Adaptive spacing
                            mainAxisSpacing:
                                isSmallScreen ? 8 : 10, // Adaptive spacing
                            childAspectRatio: isSmallScreen
                                ? 1.3
                                : 1.5, // Adaptive aspect ratio
                            children: _expensesByCategory.entries
                                .toList()
                                .map((entry) => _buildCategoryCard(
                                      entry.key,
                                      entry.value,
                                      isSmallScreen,
                                    ))
                                .toList(),
                          );
                        }),
                      ),
                    ),

                    SizedBox(
                        height: isSmallScreen ? 16 : 24), // Adaptive spacing
                  ],

                  // Recent Expenses Section
                  FadeTransition(
                    opacity: listViewsAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Expenses',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 16
                                    : 18, // Adaptive font size
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            TextButton(
                              onPressed: _openAddExpenseOverlay,
                              child: Text(
                                '+ Add New',
                                style: TextStyle(
                                    fontSize: isSmallScreen
                                        ? 12
                                        : 14), // Adaptive font size
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        _registeredExpenses.isEmpty
                            ? Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen
                                      ? 12
                                      : 16), // Adaptive padding
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: isSmallScreen
                                            ? 36
                                            : 48, // Adaptive icon size
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No expenses yet',
                                        style: TextStyle(
                                          fontSize: isSmallScreen
                                              ? 14
                                              : 16, // Adaptive font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add your first expense to start tracking',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isSmallScreen
                                              ? 12
                                              : 14, // Adaptive font size
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _openAddExpenseOverlay,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: isSmallScreen
                                              ? const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8)
                                              : null, // Adaptive padding
                                        ),
                                        child: Text(
                                          'Add Expense',
                                          style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 12
                                                  : 14), // Adaptive font size
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: isSmallScreen
                                    ? 250
                                    : 300, // Adaptive height
                                child: ExpensesList(
                                  expenses: _registeredExpenses,
                                  onRemoveExpense: _removeExpense,
                                ),
                              ),

                        SizedBox(
                            height:
                                isSmallScreen ? 16 : 24), // Adaptive spacing

                        // Recent Incomes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Incomes',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 16
                                    : 18, // Adaptive font size
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            TextButton(
                              onPressed: _openAddIncomeOverlay,
                              child: Text(
                                '+ Add New',
                                style: TextStyle(
                                    fontSize: isSmallScreen
                                        ? 12
                                        : 14), // Adaptive font size
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        _registeredIncomes.isEmpty
                            ? Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen
                                      ? 12
                                      : 16), // Adaptive padding
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        size: isSmallScreen
                                            ? 36
                                            : 48, // Adaptive icon size
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No incomes yet',
                                        style: TextStyle(
                                          fontSize: isSmallScreen
                                              ? 14
                                              : 16, // Adaptive font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add your first income to start tracking',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: isSmallScreen
                                              ? 12
                                              : 14, // Adaptive font size
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _openAddIncomeOverlay,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: isSmallScreen
                                              ? const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8)
                                              : null, // Adaptive padding
                                        ),
                                        child: Text(
                                          'Add Income',
                                          style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 12
                                                  : 14), // Adaptive font size
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: isSmallScreen
                                    ? 250
                                    : 300, // Adaptive height
                                child: IncomesList(
                                  incomes: _registeredIncomes,
                                  onRemoveIncome: _removeIncome,
                                ),
                              ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 16), // Adaptive spacing
                ],
              ),
            ),
          );

    // Using SafeArea to ensure content doesn't get cut off on notched devices
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _navigateToProfileScreen,
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              iconSize: isSmallScreen ? 20 : 24, // Adaptive icon size
            ),
            IconButton(
              onPressed: _navigateToSearchScreen,
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              iconSize: isSmallScreen ? 20 : 24, // Adaptive icon size
            ),
            IconButton(
              onPressed: _navigateToSettingsScreen,
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              iconSize: isSmallScreen ? 20 : 24, // Adaptive icon size
            ),
          ],
        ),
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddExpenseOverlay,
          elevation: 4,
          mini: isSmallScreen, // Use mini FAB on small screens
          child: Icon(
            Icons.add,
            size: isSmallScreen ? 20 : 24, // Adaptive icon size
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          elevation: 8.0,
          child: SizedBox(
            height: isSmallScreen ? 48 : 56, // Adaptive height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onItemTapped(0),
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart,
                  label: 'Budgets',
                  isSelected: _selectedIndex == 1,
                  onTap: _navigateToBudgetsScreen,
                  isSmallScreen: isSmallScreen,
                ),
                // Empty space for the FAB
                const Expanded(child: SizedBox()),
                _buildNavItem(
                  icon: Icons.pie_chart,
                  label: 'Reports',
                  isSelected: _selectedIndex == 2,
                  onTap: _navigateToReportsScreen,
                  isSmallScreen: isSmallScreen,
                ),
                _buildNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Income',
                  isSelected: false,
                  onTap: _openAddIncomeOverlay,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, IconData icon,
      Color color, bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure minimum height
      children: [
        Row(
          mainAxisSize: MainAxisSize.min, // Prevent row from expanding too much
          children: [
            Icon(icon,
                color: color, size: isSmallScreen ? 12 : 14), // Adaptive size
            SizedBox(width: isSmallScreen ? 2 : 4), // Adaptive spacing
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 10 : 12, // Adaptive font size
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 1 : 2), // Adaptive spacing
        Text(
          SettingsService.formatCurrency(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 12 : 14, // Adaptive font size
          ),
          maxLines: 1, // Ensure single line
          overflow: TextOverflow.ellipsis, // Handle text overflow
        ),
      ],
    );
  }

  Widget _buildMonthlyCard(String title, double amount, IconData icon,
      Color color, bool isSmallScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12), // Adaptive padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Theme.of(context).cardColor,
                    color.withOpacity(0.1),
                  ]
                : [
                    Colors.white,
                    color.withOpacity(0.05),
                  ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensure column takes minimum height
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.all(isSmallScreen ? 4 : 6), // Adaptive padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: color,
                      size: isSmallScreen ? 14 : 16), // Adaptive icon size
                ),
                SizedBox(width: isSmallScreen ? 6 : 8), // Adaptive spacing
                Expanded(
                  // Wrap text in Expanded to prevent overflow
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14, // Adaptive font size
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 8), // Adaptive spacing
            Text(
              SettingsService.formatCurrency(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 18, // Adaptive font size
                color: isDarkMode
                    ? color.withOpacity(0.9)
                    : color.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis, // Handle text overflow
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      Category category, double amount, bool isSmallScreen) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // Adaptive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensure column takes minimum height
          children: [
            Row(
              children: [
                Icon(
                  categoryIcons[category],
                  color: Theme.of(context).colorScheme.primary,
                  size: isSmallScreen ? 14 : 16, // Adaptive icon size
                ),
                SizedBox(width: isSmallScreen ? 2 : 4), // Adaptive spacing
                Expanded(
                  // Wrap in Expanded to prevent overflow
                  child: Text(
                    category.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 10 : 12, // Adaptive font size
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 2 : 4), // Adaptive spacing
            Text(
              SettingsService.formatCurrency(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14, // Adaptive font size
              ),
              overflow: TextOverflow.ellipsis, // Handle text overflow
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      // Wrap in Expanded to distribute space evenly
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : null,
              size: isSmallScreen ? 18 : 20, // Adaptive icon size
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10, // Adaptive font size
                color: isSelected ? primaryColor : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
              overflow: TextOverflow.ellipsis, // Handle potential overflow
            ),
            // Remove the selected indicator to save space
          ],
        ),
      ),
    );
  }
}
