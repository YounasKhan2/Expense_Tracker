import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseScreen extends StatelessWidget {
  final String? expenseId;
  final Map<String, dynamic>? initialData;

  const ExpenseScreen({super.key, this.expenseId, this.initialData});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: initialData?['name'] ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: initialData?['amount']?.toString() ?? '',
    );
    final List<String> categories = [
      'Food',
      'Transportation',
      'Utilities',
      'Entertainment',
      'Shopping',
      'Health',
      'Education',
      'Housing',
      'Personal',
    ];
    String selectedCategory = initialData?['category'] ?? categories.first;

    void saveExpense() async {
      String name = nameController.text.trim();
      String amount = amountController.text.trim();

      if (name.isEmpty || amount.isEmpty || selectedCategory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
        return;
      }

      double? amountValue = double.tryParse(amount);
      if (amountValue == null || amountValue <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount must be a positive number.')),
        );
        return;
      }

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final expenseData = {
          'name': name,
          'amount': double.parse(amount),
          'category': selectedCategory,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId, // Ensure userId is stored for querying
        };

        if (expenseId != null) {
          // Update existing expense
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .doc(expenseId)
              .update(expenseData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1200),
            ),
          );
          Navigator.of(context).pop();
        } else {
          // Add new expense
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .add(expenseData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1200),
            ),
          );
          nameController.clear();
          amountController.clear();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          expenseId != null ? 'Edit Expense' : 'Add Expense',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items:
                  categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                expenseId != null ? 'Update Expense' : 'Add Expense',
                style: const TextStyle(
                  color: Colors.white, // Ensure text is visible
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
