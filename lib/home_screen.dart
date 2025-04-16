import 'package:flutter/material.dart';
import 'expense_entry_screen.dart'; // Ensure this import is correct
import 'expense_list_screen.dart'; // Import ExpenseListScreen
import 'expense_split_screen.dart'; // Import ExpenseSplitScreen

class MyHomePage extends StatelessWidget {
  final String username;
  const MyHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Expense Locator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username, Welcome to Expense Locator!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()),
                );
              },
              child: const Text('Enter Expenses'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ExpenseSplitScreen()),
                );
              },
              child: const Text('Split Costs'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ExpenseListScreen()),
                );
              },
              child: const Text('View Expense History'),
            ),
          ],
        ),
      ),
    );
  }
}
