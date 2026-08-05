import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'masters_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double todayTotal = 0;
  double monthTotal = 0;

  @override
  void initState() {
    super.initState();
    loadTotals();
  }

  Future<void> loadTotals() async {
    final totals = await DatabaseHelper.instance.getDashboardTotals();
    if (!mounted) return;
    setState(() {
      todayTotal = totals['today'] ?? 0;
      monthTotal = totals['month'] ?? 0;
    });
  }

  Future<void> openScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    await loadTotals();
  }

  Widget menuButton(
    IconData icon,
    String title,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          label: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget summaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.currency_rupee, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPI Fleet'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/image/gpi_logo.png', height: 120),
            const SizedBox(height: 20),
            summaryCard("Today's Expense", todayTotal, Colors.blue),
            summaryCard('This Month', monthTotal, Colors.green),
            const SizedBox(height: 20),
            menuButton(
              Icons.add_circle,
              'New Expense',
              Colors.blue,
              () => openScreen(const AddExpenseScreen()),
            ),
            menuButton(
              Icons.history,
              'Expense History',
              Colors.green,
              () => openScreen(const ExpenseHistoryScreen()),
            ),
            menuButton(
              Icons.settings,
              'Masters',
              Colors.purple,
              () => openScreen(const MastersScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
