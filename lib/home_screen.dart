import 'package:flutter/material.dart';
import 'expense_entry_screen.dart';
import 'expense_list_screen.dart';
import 'expense_split_screen.dart';
import 'custom_bottom_navigation_bar.dart';

class MyHomePage extends StatefulWidget {
  final String username;
  const MyHomePage({super.key, required this.username});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 3; // Home tab is selected by default

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Reminders
        // Navigate to Reminders screen if you have one
        break;
      case 1: // Receipt
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpenseListScreen()),
        );
        break;
      case 2: // Statistics
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExpenseSplitScreen()),
        );
        break;
      case 3: // Home
        // Already on home
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2B5D),
        title: const Text('Expense Locator',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add settings functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.username}, Welcome to Expense Locator!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2B5D),
                ),
              ),
              const SizedBox(height: 24),
              // Enter Expenses Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.add_circle, color: Color(0xFF4A2B5D)),
                  title: const Text('Enter Expenses'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ExpenseEntryScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Split Costs Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.people, color: Color(0xFF4A2B5D)),
                  title: const Text('Split Costs'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ExpenseSplitScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // View Expense History Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.receipt_long, color: Color(0xFF4A2B5D)),
                  title: const Text('View Expense History'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ExpenseListScreen()),
                    );
                  },
                ),
              ),
            ],
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ExpenseEntryScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
