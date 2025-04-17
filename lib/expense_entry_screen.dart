import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'database_helper.dart';
import 'custom_bottom_navigation_bar.dart';
import 'expense_list_screen.dart';
import 'expense_split_screen.dart';
import 'home_screen.dart';

class ExpenseEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? initialExpense;
  const ExpenseEntryScreen({super.key, this.initialExpense});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isExpense = true; // Toggle between Expense and Income
  bool _isSaving = false;
  int _currentIndex = 1; // Set to 1 for Receipt tab

  // Create database helper instance
  late final DatabaseHelper _dbHelper;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Bill & Utility',
    'Shopping',
    'Education'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize database helper
    _dbHelper = DatabaseHelper();

    // Debug database status
    _dbHelper.debugDatabase();

    // Initialize data
    if (widget.initialExpense != null) {
      _titleController.text = widget.initialExpense!['title'];
      _amountController.text = widget.initialExpense!['amount'].toString();
      _selectedCategory = widget.initialExpense!['category'];
      _selectedDate = DateTime.parse(widget.initialExpense!['date']);
      _isExpense = widget.initialExpense!['isShared'] ==
          0; // isShared 0 = Expense, 1 = Income
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = 'Bill & Utility'; // Default category
    }
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    // Show visual indication and check if already processing
    if (_isSaving) {
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate fields not covered by form validation
    if (_selectedDate == null) {
      Fluttertoast.showToast(msg: 'Please select a date.');
      return;
    }

    if (_selectedCategory == null) {
      Fluttertoast.showToast(msg: 'Please select a category.');
      return;
    }

    // Set loading state
    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare expense data
      final expense = {
        'title': _titleController.text,
        'category': _selectedCategory,
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'date': _selectedDate!.toIso8601String(),
        'isShared': _isExpense ? 0 : 1, // isShared 0 = Expense, 1 = Income
      };

      int result;

      // Update or insert based on whether we have an initial expense
      if (widget.initialExpense != null) {
        result = await _dbHelper.updateExpense(
          widget.initialExpense!['id'],
          expense,
        );
      } else {
        result = await _dbHelper.insertExpense(expense);
      }

      // Handle result
      if (result > 0) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to save expense.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2B5D),
        title: const Text('Add New Expense',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add settings functionality
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Toggle between Expense and Income
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpense = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpense
                                    ? const Color(0xFF4A2B5D)
                                    : Colors.grey[300],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _isExpense
                                        ? Colors.white
                                        : Colors.black,
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
                                _isExpense = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpense
                                    ? const Color(0xFF4A2B5D)
                                    : Colors.grey[300],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: !_isExpense
                                        ? Colors.white
                                        : Colors.black,
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
                  const SizedBox(height: 16),
                  // Date selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Select date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Color(0xFF4A2B5D)),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category dropdown
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF4A2B5D)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Description (Optional)',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Total',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Receipt images section
                  const Text(
                    'Expense receipt images',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.white, size: 16),
                                onPressed: () {
                                  // Image picking functionality
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.white, size: 16),
                                onPressed: () {
                                  // Image picking functionality
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4A2B5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveExpense,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF4A2B5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Already on add expense screen
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
