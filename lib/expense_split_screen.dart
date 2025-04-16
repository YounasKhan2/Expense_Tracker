import 'package:flutter/material.dart';

class ExpenseSplitScreen extends StatefulWidget {
  const ExpenseSplitScreen({super.key});

  @override
  State<ExpenseSplitScreen> createState() => _ExpenseSplitScreenState();
}

class _ExpenseSplitScreenState extends State<ExpenseSplitScreen> {
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _customPercentageController = TextEditingController();
  String _selectedModel = 'Equal Split';
  String _result = '';

  void _calculateSplit() {
    final totalAmount = double.tryParse(_totalAmountController.text);
    if (totalAmount == null || totalAmount <= 0) {
      setState(() {
        _result = 'Please enter a valid total amount.';
      });
      return;
    }

    if (_selectedModel == 'Equal Split') {
      final splitAmount = totalAmount / 2;
      setState(() {
        _result = 'Each user pays: PKR${splitAmount.toStringAsFixed(2)}';
      });
    } else if (_selectedModel == 'Custom Percentage Split') {
      final customPercentage = double.tryParse(_customPercentageController.text);
      if (customPercentage == null || customPercentage <= 0 || customPercentage > 100) {
        setState(() {
          _result = 'Please enter a valid percentage (1-100).';
        });
        return;
      }
      final userAShare = totalAmount * (customPercentage / 100);
      final userBShare = totalAmount - userAShare;
      setState(() {
        _result = 'User A pays: PKR${userAShare.toStringAsFixed(2)}, '
            'User B pays: PKR${userBShare.toStringAsFixed(2)}';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            DropdownButtonFormField<String>(
              value: _selectedModel,
              items: const [
                DropdownMenuItem(value: 'Equal Split', child: Text('Equal Split')),
                DropdownMenuItem(value: 'Custom Percentage Split', child: Text('Custom Percentage Split')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedModel = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Split Model',
                border: OutlineInputBorder(),
              ),
            ),
            if (_selectedModel == 'Custom Percentage Split') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customPercentageController,
                decoration: const InputDecoration(
                  labelText: 'User A\'s Percentage (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
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
