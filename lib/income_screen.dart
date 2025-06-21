import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomeScreen extends StatelessWidget {
  final String? incomeId;
  final Map<String, dynamic>? initialData;

  const IncomeScreen({super.key, this.incomeId, this.initialData});

  @override
  Widget build(BuildContext context) {
    final TextEditingController sourceController = TextEditingController(
      text: initialData?['source'] ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: initialData?['amount']?.toString() ?? '',
    );

    void saveIncome() async {
      String source = sourceController.text.trim();
      String amount = amountController.text.trim();

      if (source.isEmpty || amount.isEmpty) {
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

        final incomeData = {
          'source': source,
          'amount': double.parse(amount),
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId, // Ensure userId is stored for querying
        };

        if (incomeId != null) {
          // Update existing income
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('incomes')
              .doc(incomeId)
              .update(incomeData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Income updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1200),
            ),
          );
        } else {
          // Add new income
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('incomes')
              .add(incomeData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Income added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1200),
            ),
          );
          sourceController.clear();
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
          incomeId != null ? 'Edit Income' : 'Add Income',
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
              controller: sourceController,
              decoration: InputDecoration(
                labelText: 'Income Source',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveIncome,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  12,
                  104,
                  16,
                ), // Darker green for better visibility
              ),
              child: Text(
                incomeId != null ? 'Update Income' : 'Add Income',
                style: TextStyle(
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
