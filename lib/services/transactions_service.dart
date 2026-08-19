import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_entry.dart';

enum TransactionType { fuel, expense, maintenance }

class TransactionRecord {
  final int id;
  final String date;
  final String truckNumber;
  final double amount;
  final TransactionType type;
  final String description;
  final dynamic originalRecord;

  TransactionRecord({
    required this.id,
    required this.date,
    required this.truckNumber,
    required this.amount,
    required this.type,
    required this.description,
    required this.originalRecord,
  });
}

class TransactionsService {
  TransactionsService._();
  static final TransactionsService instance = TransactionsService._();

  Future<List<TransactionRecord>> getAllTransactions({
    int? truckId,
    String? startDate,
    String? endDate,
    String? searchTerm,
    TransactionType? filterType,
  }) async {
    List<TransactionRecord> all = [];

    // 1. Fetch Fuel
    if (filterType == null || filterType == TransactionType.fuel) {
      try {
        final fuel = await DatabaseHelper.instance.queryFuelEntries(
          truckId: truckId,
          startDate: startDate,
          endDate: endDate,
          searchTerm: searchTerm,
        );
        all.addAll(fuel.map((m) {
          final entry = FuelEntry.fromMap(m);
          return TransactionRecord(
            id: entry.id!,
            date: entry.date,
            truckNumber: entry.truckNumber ?? '',
            amount: entry.totalAmount,
            type: TransactionType.fuel,
            description: entry.fuelStation ?? 'Fuel Entry',
            originalRecord: entry,
          );
        }));
      } catch (e) {
        debugPrint('Error fetching fuel for combined list: $e');
      }
    }

    // 2. Fetch Expenses
    if (filterType == null || filterType == TransactionType.expense) {
      try {
        final expenses = await DatabaseHelper.instance.getExpenses();
        var filteredExpenses = expenses;
        if (truckId != null) {
          filteredExpenses = filteredExpenses.where((e) => e['truck_id'] == truckId).toList();
        }
        if (startDate != null && endDate != null) {
          filteredExpenses = filteredExpenses.where((e) {
            final d = e['date'].toString();
            return d.compareTo(startDate) >= 0 && d.compareTo(endDate) <= 0;
          }).toList();
        }
        if (searchTerm != null && searchTerm.isNotEmpty) {
          final s = searchTerm.toLowerCase();
          filteredExpenses = filteredExpenses.where((e) => 
            (e['truck_no']?.toString().toLowerCase().contains(s) ?? false) ||
            (e['expense_name']?.toString().toLowerCase().contains(s) ?? false) ||
            (e['remarks']?.toString().toLowerCase().contains(s) ?? false)
          ).toList();
        }

        all.addAll(filteredExpenses.map((m) => TransactionRecord(
          id: m['id'],
          date: m['date'],
          truckNumber: m['truck_no'] ?? '',
          amount: (m['amount'] as num).toDouble(),
          type: TransactionType.expense,
          description: m['expense_name'] ?? 'General Expense',
          originalRecord: m,
        )));
      } catch (e) {
        debugPrint('Error fetching expenses for combined list: $e');
      }
    }

    // 3. Fetch Maintenance
    if (filterType == null || filterType == TransactionType.maintenance) {
      try {
        final maintenance = await DatabaseHelper.instance.queryMaintenanceEntries(
          truckId: truckId,
          startDate: startDate,
          endDate: endDate,
          searchTerm: searchTerm,
        );
        all.addAll(maintenance.map((m) {
          final entry = MaintenanceEntry.fromMap(m);
          return TransactionRecord(
            id: entry.id!,
            date: entry.date,
            truckNumber: entry.truckNumber ?? '',
            amount: entry.amount,
            type: TransactionType.maintenance,
            description: entry.maintenanceType,
            originalRecord: entry,
          );
        }));
      } catch (e) {
        debugPrint('Error fetching maintenance for combined list: $e');
      }
    }

    // Sort newest first
    all.sort((a, b) {
      int cmp = b.date.compareTo(a.date);
      if (cmp != 0) return cmp;
      return b.id.compareTo(a.id);
    });

    return all;
  }
}
