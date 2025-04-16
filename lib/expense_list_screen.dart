import 'package:flutter/material.dart';
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
    final expenses = await DatabaseHelper().getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper().deleteExpense(id);
    Fluttertoast.showToast(msg: 'Expense deleted successfully!');
    _loadExpenses();
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
                'Date: ${DateTime.parse(expense['date']).toLocal()}'.split(' ')[0],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('\$${expense['amount']}'),
                  if (expense['isShared'] == 1)
                    const Text(
                      'Shared',
                      style: TextStyle(color: Colors.green),
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
    );
  }
}

