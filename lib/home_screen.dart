import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:expense_tracker/expense_list_screen.dart';
import 'package:expense_tracker/income_list_screen.dart';
import 'settings_screen.dart';
import 'bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [HomeContent(), SettingsScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
=======
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
>>>>>>> e05858728bd3e8d67f601764faefb529890e3e4c
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
              }
=======
        backgroundColor: const Color(0xFF4A2B5D),
        title: const Text('Expense Locator',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Add settings functionality
>>>>>>> e05858728bd3e8d67f601764faefb529890e3e4c
            },
          ),
        ],
      ),
<<<<<<< HEAD
      body: _pages[_selectedIndex],
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildOverviewCards(context, userId),
                const SizedBox(height: 24),
                _buildSummarySection(context, userId),
                const SizedBox(height: 24),
                _buildQuickActions(context, userId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Text(
                'User',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final name = data?['name'] ?? 'User';
            return Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context, String userId) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            title: 'Expenses',
            icon: Icons.money_off_rounded,
            backgroundColor: const Color(0xFFF26F6D),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExpenseListScreen(userId: userId),
                ),
              );
            },
            streamBuilder: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('expenses') // Correct Firestore path
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No expenses');
                }

                double total = 0.0;
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  total += (data['amount'] as num).toDouble();
                }

                return Text(
                  '${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            context,
            title: 'Income',
            icon: Icons.account_balance_wallet_rounded,
            backgroundColor: const Color(0xFF66BB6A),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncomeListScreen(userId: userId),
                ),
              );
            },
            streamBuilder: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('incomes') // Correct Firestore path
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No incomes');
                }

                double total = 0.0;
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  total += (data['amount'] as num).toDouble();
                }

                return Text(
                  '${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Widget streamBuilder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shadowColor: backgroundColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: backgroundColor,
=======
      body: SafeArea(
>>>>>>> e05858728bd3e8d67f601764faefb529890e3e4c
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              streamBuilder,
              const SizedBox(height: 4),
              Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, String userId) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('incomes')
                      .snapshots(),
              builder: (context, incomeSnapshot) {
                if (incomeSnapshot.hasError) {
                  return const Center(child: Text('Error loading incomes'));
                }

                if (!incomeSnapshot.hasData ||
                    incomeSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No incomes found'));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('expenses')
                          .snapshots(),
                  builder: (context, expenseSnapshot) {
                    if (expenseSnapshot.hasError) {
                      return const Center(
                        child: Text('Error loading expenses'),
                      );
                    }

                    if (!expenseSnapshot.hasData ||
                        expenseSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No expenses found'));
                    }

                    final incomeDocs = incomeSnapshot.data!.docs;
                    final expenseDocs = expenseSnapshot.data!.docs;

                    double totalIncome = 0.0;
                    for (var doc in incomeDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      totalIncome += (data['amount'] as num).toDouble();
                    }

                    double totalExpenses = 0.0;
                    for (var doc in expenseDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      totalExpenses += (data['amount'] as num).toDouble();
                    }

                    final balance = totalIncome - totalExpenses;
                    final isPositive = balance >= 0;

                    return Column(
                      children: [
                        _buildSummaryItem(
                          'Total Balance',
                          '${balance.abs().toStringAsFixed(0)}',
                          isPositive ? Colors.green : Colors.red,
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                'Income',
                                '${totalIncome.toStringAsFixed(0)}',
                                Colors.green,
                                Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryItem(
                                'Expenses',
                                '${totalExpenses.toStringAsFixed(0)}',
                                Colors.red,
                                Icons.trending_down,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
=======
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
>>>>>>> e05858728bd3e8d67f601764faefb529890e3e4c
                ),
              ),
            ],
          ),
        ),
<<<<<<< HEAD
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, String userId) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add_circle,
                  label: 'Add Expense',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ExpenseListScreen(userId: userId),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.add_chart,
                  label: 'Add Income',
                  color: Colors.greenAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => IncomeListScreen(userId: userId),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
=======
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
>>>>>>> e05858728bd3e8d67f601764faefb529890e3e4c
    );
  }
}
