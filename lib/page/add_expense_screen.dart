import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.expense});

  final Map<String, dynamic>? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final expenseController = TextEditingController();
  final remarksController = TextEditingController();
  final otherController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> drivers = [];
  List<Map<String, dynamic>> trucks = [];
  int? selectedDriverId;
  int? selectedTruckId;
  String paidBy = 'Ankur';
  String paymentMode = 'Cash';
  bool isSaving = false;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _loadExpenseForEditing();
    loadData();
  }

  void _loadExpenseForEditing() {
    final expense = widget.expense;
    if (expense == null) return;

    selectedDate = _parseDate(expense['date'] as String?);
    selectedDriverId = expense['driver_id'] as int?;
    selectedTruckId = expense['truck_id'] as int?;
    amountController.text = expense['amount'].toString();
    expenseController.text = expense['expense_name'] as String? ?? '';
    remarksController.text = expense['remarks'] as String? ?? '';
    paymentMode = expense['payment_mode'] as String? ?? 'Cash';

    const standardPayers = {'Ankur', 'Himanshu', 'Mukesh'};
    final savedPayer = expense['paid_by'] as String? ?? 'Ankur';
    if (standardPayers.contains(savedPayer)) {
      paidBy = savedPayer;
    } else {
      paidBy = 'Other';
      otherController.text = savedPayer;
    }
  }

  DateTime _parseDate(String? value) {
    if (value == null) return DateTime.now();
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;

    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }

  Future<void> loadData() async {
    final loadedDrivers = await DatabaseHelper.instance.getDrivers();
    final loadedTrucks = await DatabaseHelper.instance.getTrucks();
    if (!mounted) return;
    setState(() {
      drivers = loadedDrivers;
      trucks = loadedTrucks;
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String get formattedDate {
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');
    return '${selectedDate.year}-$month-$day';
  }

  Future<void> saveExpense() async {
    if (isSaving || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);
    final expense = <String, dynamic>{
      'date': formattedDate,
      'driver_id': selectedDriverId,
      'truck_id': selectedTruckId,
      'amount': double.parse(amountController.text.trim()),
      'paid_by': paidBy == 'Other' ? otherController.text.trim() : paidBy,
      'payment_mode': paymentMode,
      'expense_name': expenseController.text.trim(),
      'remarks': remarksController.text.trim(),
    };

    try {
      if (isEditing) {
        await DatabaseHelper.instance.updateExpense(
          widget.expense!['id'] as int,
          expense,
        );
      } else {
        await DatabaseHelper.instance.addExpense(expense);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Expense updated successfully' : 'Expense saved successfully',
          ),
        ),
      );
      if (isEditing) {
        Navigator.pop(context, true);
        return;
      }

      amountController.clear();
      expenseController.clear();
      remarksController.clear();
      otherController.clear();
      setState(() {
        selectedDriverId = null;
        selectedTruckId = null;
        paidBy = 'Ankur';
        paymentMode = 'Cash';
        selectedDate = DateTime.now();
      });
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    expenseController.dispose();
    remarksController.dispose();
    otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'New Expense'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: formattedDate),
              decoration: InputDecoration(
                labelText: 'Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: pickDate,
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: selectedDriverId,
              decoration: const InputDecoration(
                labelText: 'Driver',
                border: OutlineInputBorder(),
              ),
              items: drivers
                  .map((driver) => DropdownMenuItem<int>(
                        value: driver['id'] as int,
                        child: Text(driver['name'] as String),
                      ))
                  .toList(),
              validator: (value) => value == null ? 'Select a driver' : null,
              onChanged: (value) => setState(() => selectedDriverId = value),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: selectedTruckId,
              decoration: const InputDecoration(
                labelText: 'Truck Number',
                border: OutlineInputBorder(),
              ),
              items: trucks
                  .map((truck) => DropdownMenuItem<int>(
                        value: truck['id'] as int,
                        child: Text(truck['truck_no'] as String),
                      ))
                  .toList(),
              validator: (value) => value == null ? 'Select a truck' : null,
              onChanged: (value) => setState(() => selectedTruckId = value),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: paidBy,
              decoration: const InputDecoration(
                labelText: 'Paid By',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Ankur', child: Text('Ankur')),
                DropdownMenuItem(value: 'Himanshu', child: Text('Himanshu')),
                DropdownMenuItem(value: 'Mukesh', child: Text('Mukesh')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => paidBy = value!),
            ),
            if (paidBy == 'Other') ...[
              const SizedBox(height: 15),
              TextFormField(
                controller: otherController,
                decoration: const InputDecoration(
                  labelText: 'Other Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the payer name'
                    : null,
              ),
            ],
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: paymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
              ],
              onChanged: (value) => setState(() => paymentMode = value!),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: expenseController,
              decoration: const InputDecoration(
                labelText: 'Expense Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter an expense name'
                  : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveExpense,
                child: Text(
                  isSaving
                      ? 'SAVING...'
                      : isEditing
                          ? 'UPDATE EXPENSE'
                          : 'SAVE EXPENSE',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
