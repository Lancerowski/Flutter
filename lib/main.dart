import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final List<Map<String, dynamic>> _expenses = [];

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  int? _editingIndex;  

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Others'
  ];

  final Map<String, Color> _categoryColors = {
    'Food': Colors.green,
    'Transport': Colors.blue,
    'Entertainment': Colors.orange,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
    'Others': Colors.yellow,
  };

  void _addExpense() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) return;

    if (_editingIndex == null) {
      setState(() {
        _expenses.add({
          'title': title,
          'amount': amount,
          'category': _selectedCategory,
        });
      });
    } else {
      setState(() {
        _expenses[_editingIndex!] = {
          'title': title,
          'amount': amount,
          'category': _selectedCategory,
        };
      });
      _editingIndex = null;  
    }

    _titleController.clear();
    _amountController.clear();
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _editExpense(int index) {
    final expense = _expenses[index];
    _titleController.text = expense['title'];
    _amountController.text = expense['amount'].toString();
    _selectedCategory = expense['category'];
    
    setState(() {
      _editingIndex = index;  // Mark the item as being edited
    });
  }

  List<PieChartSectionData> _getChartData() {
    final Map<String, double> categorySums = {};

    for (var expense in _expenses) {
      final category = expense['category'];
      final amount = expense['amount'];
      categorySums[category] = (categorySums[category] ?? 0) + amount;
    }

    List<PieChartSectionData> sections = [];
    categorySums.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: _categoryColors[category]!,
          value: amount,
          title: '${category[0]}: \$${amount.toStringAsFixed(2)}',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (newCategory) {
                setState(() {
                  _selectedCategory = newCategory!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text(_editingIndex == null ? 'Add Expense' : 'Update Expense'),
            ),
            const SizedBox(height: 20),
            const Text('Expenses:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (ctx, index) {
                  final expense = _expenses[index];
                  return Card(
                    child: ListTile(
                      title: Text(expense['title']),
                      subtitle: Text(
                        '${expense['category']} - \$${expense['amount'].toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExpense(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteExpense(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Expense Distribution:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _getChartData(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _categoryColors.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                color: entry.value,
              ),
              const SizedBox(width: 5),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
    );
  }
}
