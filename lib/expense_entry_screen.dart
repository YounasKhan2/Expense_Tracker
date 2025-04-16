import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'database_helper.dart';
import 'dart:io'; // Import for platform checks

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
  bool _isShared = false;
  bool _isSaving = false;

  // Create database helper instance
  late final DatabaseHelper _dbHelper;

  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Shopping'];

  @override
  void initState() {
    super.initState();

    // Initialize database helper
    _dbHelper = DatabaseHelper();

    // Debug database status
    _dbHelper.debugDatabase();

    // Initialize data
    if (widget.initialExpense != null) {
      debugPrint("Initializing form with existing expense: ${widget.initialExpense}");
      _titleController.text = widget.initialExpense!['title'];
      _amountController.text = widget.initialExpense!['amount'].toString();
      _selectedCategory = widget.initialExpense!['category'];
      _selectedDate = DateTime.parse(widget.initialExpense!['date']);
      _isShared = widget.initialExpense!['isShared'] == 1;
    } else {
      debugPrint("Initializing form for new expense");
      _selectedDate = DateTime.now();
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
      debugPrint("Date selected: ${pickedDate.toIso8601String()}");
    }
  }

  Future<void> _saveExpense() async {
    // Show visual indication and check if already processing
    debugPrint("Save button pressed");
    if (_isSaving) {
      debugPrint("Already saving, ignoring button press");
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      debugPrint("Form validation failed");
      return;
    }

    // Validate fields not covered by form validation
    if (_selectedDate == null) {
      debugPrint("No date selected");
      Fluttertoast.showToast(msg: 'Please select a date.');
      return;
    }

    if (_selectedCategory == null) {
      debugPrint("No category selected");
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
        'isShared': _isShared ? 1 : 0,
      };

      debugPrint("Prepared expense data: $expense");

      int result;

      // Update or insert based on whether we have an initial expense
      if (widget.initialExpense != null) {
        debugPrint("Updating expense with ID: ${widget.initialExpense!['id']}");
        result = await _dbHelper.updateExpense(
          widget.initialExpense!['id'],
          expense,
        );
      } else {
        debugPrint("Inserting new expense");
        result = await _dbHelper.insertExpense(expense);
      }

      debugPrint("Database operation result: $result");

      // Handle result
      if (result > 0) {
        debugPrint("Operation successful, navigating back");
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        debugPrint("Operation failed with result: $result");
        Fluttertoast.showToast(msg: 'Failed to save expense.');
      }
    } catch (e) {
      debugPrint("Error during save operation: $e");
      Fluttertoast.showToast(msg: 'Error: $e');
    } finally {
      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        debugPrint("Reset save button state");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialExpense != null ? 'Edit Expense' : 'New Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount Spent',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Share Expense'),
                value: _isShared,
                onChanged: (value) {
                  setState(() {
                    _isShared = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Saving...'),
                    ],
                  )
                      : const Text('Save Expense', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

