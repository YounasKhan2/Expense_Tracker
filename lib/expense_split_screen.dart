import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import DatabaseHelper

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

  void _updatePersonFields() {
    final persons = int.tryParse(_personsController.text) ?? 0;
    setState(() {
      _personDetails = List.generate(persons, (index) {
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
      return;
    }

    if (persons == null || persons <= 0) {
      setState(() {
        _result = 'Please enter a valid number of persons.';
      });
      return;
    }

    if (_selectedModel == 'Equal Split') {
      final splitAmount = totalAmount / persons;
      setState(() {
        _result = 'Each person pays: PKR${splitAmount.toStringAsFixed(2)}';
      });
    } else if (_selectedModel == 'Custom Percentage Split') {
      double totalPercentage = 0;
      for (var person in _personDetails) {
        final percentage = double.tryParse(person['percentage'] ?? '');
        if (percentage == null || percentage <= 0 || percentage > 100) {
          setState(() {
            _result = 'Please enter valid percentages for all persons.';
          });
          return;
        }
        totalPercentage += percentage;
      }

      if (totalPercentage != 100) {
        setState(() {
          _result = 'Total percentage must equal 100%.';
        });
        return;
      }

      setState(() {
        _result = _personDetails
            .map((person) {
              final percentage = double.parse(person['percentage']);
              final share = totalAmount * (percentage / 100);
              return '${person['name']} pays: PKR${share.toStringAsFixed(2)}';
            })
            .join('\n');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Costs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: 'Total Expense Amount (PKR)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _personsController,
              decoration: const InputDecoration(
                labelText: 'Number of Persons',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _updatePersonFields(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedModel,
              items: const [
                DropdownMenuItem(value: 'Equal Split', child: Text('Equal Split')),
                DropdownMenuItem(value: 'Custom Percentage Split', child: Text('Custom Percentage Split')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedModel = value!;
                  _updatePersonFields();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Split Model',
                border: OutlineInputBorder(),
              ),
            ),
            if (_selectedModel == 'Custom Percentage Split') ...[
              const SizedBox(height: 16),
              ..._personDetails.asMap().entries.map((entry) {
                final index = entry.key;
                final person = entry.value;
                return Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Person ${index + 1} Name',
                        border: const OutlineInputBorder(), // Corrected here
                      ),
                      onChanged: (value) {
                        person['name'] = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Person ${index + 1} Percentage (%)',
                        border: const OutlineInputBorder(), // Corrected here
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        person['percentage'] = value;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            ElevatedButton(
              onPressed: _calculateSplit,
              child: const Text('Calculate Split'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
