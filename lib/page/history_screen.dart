import 'package:flutter/material.dart';


import '../database/database_helper.dart';
import '../services/excel_service.dart';
import '../services/pdf_service.dart';
import 'add_expense_screen.dart';
import '../services/share_service.dart';
class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  List<Map<String, dynamic>> expenses = [];
  String selectedTruck = 'All Trucks';
  String appliedTruck = 'All Trucks';
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  DateTime? appliedFromDate;
  DateTime? appliedToDate;
  bool isExporting = false;

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedFromDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selectedFromDate = picked);
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedToDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => selectedToDate = picked);
  }

  void applyFilters() {
    setState(() {
      appliedTruck = selectedTruck;
      appliedFromDate = selectedFromDate;
      appliedToDate = selectedToDate;
    });
  }

  void clearFilters() {
    setState(() {
      selectedTruck = 'All Trucks';
      appliedTruck = 'All Trucks';
      selectedFromDate = null;
      selectedToDate = null;
      appliedFromDate = null;
      appliedToDate = null;
    });
  }

  String formatDate(DateTime? date, String label) {
    if (date == null) return label;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime? readExpenseDate(String value) {
    final date = DateTime.tryParse(value);
    if (date != null) return DateTime(date.year, date.month, date.day);

    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
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

  Future<void> _exportSelection(String format) async {
    if (!mounted) return;
    Navigator.pop(context);
    if (!mounted) return;

    setState(() => isExporting = true);
    try {
      final filteredExpenses = _filteredExpensesList();

      if (format == 'pdf') {
        final pdfPath = await PdfService.generateExpenseReport(
          expenses: filteredExpenses,
          truckFilter: appliedTruck,
          fromDate: appliedFromDate,
          toDate: appliedToDate,
        );
        if (pdfPath != null && mounted) {
          await ShareService.shareFile(pdfPath);

        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to export PDF file.')),
          );
        }
      } else {
        final excelPath = await ExcelService.exportExpenseReport(
          expenses: filteredExpenses,
          truckFilter: appliedTruck,
          fromDate: appliedFromDate,
          toDate: appliedToDate,
        );
        if (excelPath != null && mounted) {
          await ShareService.shareFile(excelPath);

        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to export Excel file.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }

  Future<void> _showExportOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Export As',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('Export PDF'),
                  onTap: () => _exportSelection('pdf'),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined),
                  title: const Text('Export Excel'),
                  onTap: () => _exportSelection('excel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final truckNumbers =
        expenses
            .map((expense) => expense['truck_no']?.toString() ?? '')
            .where((truck) => truck.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filteredExpenses = expenses.where((expense) {
      final matchesTruck =
          appliedTruck == 'All Trucks' ||
          expense['truck_no']?.toString() == appliedTruck;
      final expenseDate = readExpenseDate(expense['date']?.toString() ?? '');
      final matchesFromDate =
          appliedFromDate == null ||
          (expenseDate != null && !expenseDate.isBefore(appliedFromDate!));
      final matchesToDate =
          appliedToDate == null ||
          (expenseDate != null && !expenseDate.isAfter(appliedToDate!));
      return matchesTruck && matchesFromDate && matchesToDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          IconButton(
            onPressed: isExporting ? null : _showExportOptions,
            icon: const Icon(Icons.download),
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              initialValue: selectedTruck,
              decoration: const InputDecoration(
                hintText: 'Select Truck',
                prefixIcon: Icon(Icons.local_shipping),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'All Trucks',
                  child: Text('All Trucks'),
                ),
                ...truckNumbers.map(
                  (truck) => DropdownMenuItem(value: truck, child: Text(truck)),
                ),
              ],
              onChanged: (value) => setState(() => selectedTruck = value!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickFromDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(formatDate(selectedFromDate, 'From Date')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickToDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(formatDate(selectedToDate, 'To Date')),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: applyFilters,
                    child: const Text('Apply Filter'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: clearFilters,
                    child: const Text('Clear Filter'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const SizedBox(height: 10),
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('No expenses found.'))
                : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      final remarks = (expense['remarks'] as String? ?? '')
                          .trim();
                      final expenseName =
                          expense['expense_name'] as String? ?? '';

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping,
                                    size: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      expense['truck_no']?.toString() ??
                                          'Deleted truck',
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
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Driver Name: ${expense['driver_name'] ?? 'Deleted driver'}',
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Date: ${expense['date']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    expenseIcon(expenseName),
                                    size: 18,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredExpensesList() {
    return expenses.where((expense) {
      final matchesTruck =
          appliedTruck == 'All Trucks' ||
          expense['truck_no']?.toString() == appliedTruck;
      final expenseDate = readExpenseDate(expense['date']?.toString() ?? '');
      final matchesFromDate =
          appliedFromDate == null ||
          (expenseDate != null && !expenseDate.isBefore(appliedFromDate!));
      final matchesToDate =
          appliedToDate == null ||
          (expenseDate != null && !expenseDate.isAfter(appliedToDate!));
      return matchesTruck && matchesFromDate && matchesToDate;
    }).toList();
  }
}
