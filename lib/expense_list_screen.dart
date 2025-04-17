import 'package:flutter/material.dart';
import 'expense_entry_screen.dart';
import 'database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'custom_bottom_navigation_bar.dart';
import 'expense_split_screen.dart';
import 'home_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _filteredExpenses = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 1; // Set to 1 for Receipt tab
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _searchController.addListener(() {
      _filterExpenses();
    });
  }

  void _filterExpenses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredExpenses = List.from(_expenses);
      } else {
        _filteredExpenses = _expenses
            .where((expense) =>
                expense['title'].toString().toLowerCase().contains(query) ||
                expense['category'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    final dbHelper = DatabaseHelper();
    final expenses = await dbHelper.getExpenses();
    final splits = await dbHelper.getSplits();

    final combinedExpenses = expenses +
        splits.map((split) {
          return {
            'title': 'Split: ${split['totalAmount']} PKR',
            'category': 'Custom Split',
            'date': DateTime.now()
                .toIso8601String(), // Use current date as fallback
            'details': split['details'],
          };
        }).toList();

    setState(() {
      _expenses = combinedExpenses;
      _filteredExpenses = List.from(combinedExpenses);
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense(int? id) async {
    if (id == null) {
      return; // Skip deletion if ID is null
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteExpense(id);
      Fluttertoast.showToast(msg: 'Expense deleted successfully!');
      _loadExpenses();
    }
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseEntryScreen(
          initialExpense: expense,
        ),
      ),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Reminders
        // Navigate to Reminders screen if you have one
        break;
      case 1: // Receipt (current screen)
        // Already on this screen
        break;
      case 2: // Statistics
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpenseSplitScreen()),
        );
        break;
      case 3: // Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const MyHomePage(username: 'User')),
        );
        break;
    }
  }

  // Helper method to format dates in the desired format
  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2B5D),
        title: const Text('Receipt', style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const MyHomePage(username: 'User')),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Settings functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Icon(Icons.search, color: Colors.grey),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExpenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _filteredExpenses[index];
                          final formattedDate = expense['date'] != null
                              ? _formatDate(expense['date'])
                              : 'No Date';

                          // Determine icon based on category
                          IconData categoryIcon = Icons.receipt;
                          if (expense['category'] == 'Food') {
                            categoryIcon = Icons.fastfood;
                          } else if (expense['category'] == 'Transport') {
                            categoryIcon = Icons.directions_car;
                          } else if (expense['category'] == 'Bill & Utility') {
                            categoryIcon = Icons.receipt_long;
                          } else if (expense['category'] == 'Shopping') {
                            categoryIcon = Icons.shopping_bag;
                          } else if (expense['category'] == 'Education') {
                            categoryIcon = Icons.school;
                          } else if (expense['category'] == 'Custom Split') {
                            categoryIcon = Icons.people;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[300],
                                  child: Icon(categoryIcon,
                                      color: Colors.white, size: 18),
                                ),
                                title: Text(
                                  expense['category'] ?? 'Unknown Category',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(formattedDate),
                                    Text(expense['title'] ?? 'No description'),
                                  ],
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  if (expense['id'] != null) {
                                    _editExpense(expense);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_filteredExpenses.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
                  60.0), // Added bottom padding to avoid overflow
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Edit functionality
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF4A2B5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Edit'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Delete functionality
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF4A2B5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Delete'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
