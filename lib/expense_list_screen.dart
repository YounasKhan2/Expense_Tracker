import 'package:flutter/material.dart';
import 'expense_entry_screen.dart'; // Ensure this import is correct
import 'database_helper.dart'; // Import DatabaseHelper
import 'package:fluttertoast/fluttertoast.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final dbHelper = DatabaseHelper(); // Ensure proper database access
    final expenses = await dbHelper.getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _deleteExpense(int id) async {
    final dbHelper = DatabaseHelper(); // Ensure proper database access
    await dbHelper.deleteExpense(id);
    Fluttertoast.showToast(msg: 'Expense deleted successfully!');
    _loadExpenses();
  }

  Future<void> _editExpense(Map<String, dynamic> expense) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseEntryScreen(
          key: Key(expense['id'].toString()),
          // Pass existing expense details for editing
          initialExpense: expense,
        ),
      ),
    );
    if (result == true) {
      _loadExpenses(); // Refresh the list if an expense was edited
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
      ),
      body: ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(expense['title']),
              subtitle: Text(
                'Category: ${expense['category']}\n'
                'Date: ${expense['date'] != null ? DateTime.parse(expense['date']).toLocal().toString().split(' ')[0] : 'N/A'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editExpense(expense),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpense(expense['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()), // Ensure correct class name
          );
          if (result == true) {
            debugPrint('Expense saved or updated successfully'); // Add debug log
            _loadExpenses(); // Refresh the list if a new expense was added
          } else {
            debugPrint('No changes made to expenses'); // Add debug log
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
