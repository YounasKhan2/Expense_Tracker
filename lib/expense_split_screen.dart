import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'custom_bottom_navigation_bar.dart';
import 'expense_entry_screen.dart';
import 'expense_list_screen.dart';
import 'home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExpenseSplitScreen extends StatefulWidget {
  const ExpenseSplitScreen({super.key});

  @override
  State<ExpenseSplitScreen> createState() => _ExpenseSplitScreenState();
}

class _ExpenseSplitScreenState extends State<ExpenseSplitScreen> {
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  String _selectedModel = 'Equal Split';
  String _result = '';
  List<Map<String, dynamic>> _personDetails = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentIndex = 2; // Set to 2 for Statistics tab

  @override
  void initState() {
    super.initState();
    _personsController.text = '2'; // Default to 2 persons
    _updatePersonFields();
  }

  void _updatePersonFields() {
    final persons = int.tryParse(_personsController.text) ?? 0;
    setState(() {
      _personDetails = List.generate(persons, (index) {
        // Preserve existing data if available
        if (index < _personDetails.length) {
          return _personDetails[index];
        }
        return {'name': '', 'percentage': ''};
      });
    });
  }

  void _calculateSplit() {
    final totalAmount = double.tryParse(_totalAmountController.text);
    final persons = int.tryParse(_personsController.text);

    if (totalAmount == null || totalAmount <= 0) {
      setState(() {
        _result = 'Please enter a valid total amount.';
      });
      Fluttertoast.showToast(msg: 'Please enter a valid total amount.');
      return;
    }

    if (persons == null || persons <= 0) {
      setState(() {
        _result = 'Please enter a valid number of persons.';
      });
      Fluttertoast.showToast(msg: 'Please enter a valid number of persons.');
      return;
    }

    if (_selectedModel == 'Equal Split') {
      final splitAmount = totalAmount / persons;
      setState(() {
        _result = 'Each person pays: \$${splitAmount.toStringAsFixed(2)}';
      });
    } else if (_selectedModel == 'Custom Percentage Split') {
      double totalPercentage = 0;

      // Validate all fields are filled
      bool allFieldsFilled = true;
      for (var person in _personDetails) {
        if (person['name'].toString().trim().isEmpty) {
          setState(() {
            _result = 'Please enter names for all persons.';
          });
          Fluttertoast.showToast(msg: 'Please enter names for all persons.');
          return;
        }

        final percentage = double.tryParse(person['percentage'] ?? '');
        if (percentage == null) {
          allFieldsFilled = false;
          break;
        }
        totalPercentage += percentage;
      }

      if (!allFieldsFilled) {
        setState(() {
          _result = 'Please enter valid percentages for all persons.';
        });
        Fluttertoast.showToast(
            msg: 'Please enter valid percentages for all persons.');
        return;
      }

      if (totalPercentage != 100) {
        setState(() {
          _result =
              'Total percentage must equal 100%. Current total: $totalPercentage%';
        });
        Fluttertoast.showToast(
            msg:
                'Total percentage must equal 100%. Current total: $totalPercentage%');
        return;
      }

      // Calculate shares
      final shares = _personDetails.map((person) {
        final percentage = double.parse(person['percentage']);
        final share = totalAmount * (percentage / 100);
        return {
          'name': person['name'],
          'percentage': percentage,
          'share': share,
        };
      }).toList();

      // Format result
      setState(() {
        _result = shares.map((share) {
          return '${share['name']} (${share['percentage']}%): \$${share['share'].toStringAsFixed(2)}';
        }).join('\n');
      });
    }
  }

  Future<void> _saveSplit() async {
    final totalAmount = double.tryParse(_totalAmountController.text);
    if (totalAmount == null || totalAmount <= 0) {
      Fluttertoast.showToast(msg: 'Please enter a valid total amount.');
      return;
    }

    if (_selectedModel == 'Equal Split') {
      final persons = int.tryParse(_personsController.text) ?? 0;
      if (persons <= 0) {
        Fluttertoast.showToast(msg: 'Please enter a valid number of persons.');
        return;
      }

      final splitDetails = List.generate(persons, (index) {
        return {
          'name': 'Person ${index + 1}',
          'percentage': 100 / persons,
        };
      });

      final split = {
        'totalAmount': totalAmount,
        'splitDetails': splitDetails,
      };

      await _dbHelper.insertSplit(split);
      Fluttertoast.showToast(msg: 'Split saved successfully!');
    } else {
      // Validate custom percentage split
      double totalPercentage = 0;
      for (var person in _personDetails) {
        if (person['name'].toString().trim().isEmpty) {
          Fluttertoast.showToast(msg: 'Please enter names for all persons.');
          return;
        }

        final percentage = double.tryParse(person['percentage'] ?? '');
        if (percentage == null || percentage <= 0 || percentage > 100) {
          Fluttertoast.showToast(
              msg: 'Please enter valid percentages for all persons.');
          return;
        }
        totalPercentage += percentage;
      }

      if (totalPercentage != 100) {
        Fluttertoast.showToast(
            msg:
                'Total percentage must equal 100%. Current total: $totalPercentage%');
        return;
      }

      final split = {
        'totalAmount': totalAmount,
        'splitDetails': _personDetails,
      };

      await _dbHelper.insertSplit(split);
      Fluttertoast.showToast(msg: 'Split saved successfully!');
    }
  }

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
      case 2: // Statistics (current screen)
        // Already on this screen
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
        title: const Text('Split Costs', style: TextStyle(color: Colors.white)),
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
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Total expense amount
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText:
                          'Total Expense Amount (\$)', // Escape the dollar sign
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Number of persons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _personsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Number of Persons',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onChanged: (_) => _updatePersonFields(),
                  ),
                ),
                const SizedBox(height: 16),
                // Split model selection
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedModel,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Equal Split', child: Text('Equal Split')),
                      DropdownMenuItem(
                          value: 'Custom Percentage Split',
                          child: Text('Custom Percentage Split')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedModel = value!;
                        _updatePersonFields();
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF4A2B5D)),
                  ),
                ),
                const SizedBox(height: 16),
                // Custom percentage fields if selected
                if (_selectedModel == 'Custom Percentage Split') ...[
                  ..._personDetails.asMap().entries.map((entry) {
                    final index = entry.key;
                    final person = entry.value;
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Person ${index + 1} Name',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                person['name'] = value;
                              });
                            },
                            controller: TextEditingController(
                                text: person['name'] ?? ''),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Person ${index + 1} Percentage (%)',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                person['percentage'] = value;
                              });
                            },
                            controller: TextEditingController(
                                text: person['percentage']?.toString() ?? ''),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _calculateSplit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2B5D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Calculate Split',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSplit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2B5D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Save Split',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                // Result display
                if (_result.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Split Result:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A2B5D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
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
    _totalAmountController.dispose();
    _personsController.dispose();
    super.dispose();
  }
}
