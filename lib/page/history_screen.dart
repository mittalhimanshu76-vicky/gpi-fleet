import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'add_expense_screen.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final loadedExpenses = await DatabaseHelper.instance.getExpenses();
    if (!mounted) return;
    setState(() => expenses = loadedExpenses);
  }

  Future<void> editExpense(Map<String, dynamic> expense) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)),
    );
    if (updated == true) await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This expense will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseHelper.instance.deleteExpense(id);
    await loadExpenses();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }

  IconData expenseIcon(String expenseName) {
    switch (expenseName) {
      case 'Diesel':
        return Icons.local_gas_station;
      case 'Fastag':
      case 'Toll Tax':
        return Icons.toll;
      case 'Driver Salary':
        return Icons.person;
      case 'Advance':
        return Icons.payments;
      case 'Food':
        return Icons.restaurant;
      case 'Hotel':
        return Icons.hotel;
      case 'Tyre Repair':
        return Icons.tire_repair;
      case 'Puncture':
        return Icons.build;
      case 'Engine Oil':
        return Icons.oil_barrel;
      case 'Grease':
        return Icons.settings;
      case 'Parking':
        return Icons.local_parking;
      case 'Loading':
        return Icons.inventory_2;
      case 'Unloading':
        return Icons.outbox;
      case 'RTO':
        return Icons.description;
      case 'Police':
        return Icons.local_police;
      case 'Washing':
        return Icons.local_car_wash;
      case 'Miscellaneous':
        return Icons.receipt_long;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense History')),
      body: expenses.isEmpty
          ? const Center(child: Text('No Expenses Found'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final remarks = (expense['remarks'] as String? ?? '').trim();
                final expenseName = expense['expense_name'] as String? ?? '';

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                expense['truck_no']?.toString() ?? 'Deleted truck',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'edit') {
                                  editExpense(expense);
                                } else {
                                  deleteExpense(expense['id'] as int);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Driver Name: ${expense['driver_name'] ?? 'Deleted driver'}'),
                        Text('Date: ${expense['date']}'),
                        Row(
                          children: [
                            Icon(
                              expenseIcon(expenseName),
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text('Expense Name: $expenseName'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${expense['amount']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Paid By: ${expense['paid_by']}'),
                        Text('Payment Mode: ${expense['payment_mode']}'),
                        if (remarks.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text('Remarks: $remarks'),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
