import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/truck.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_entry.dart';
import '../services/truck_service.dart';
import '../services/transactions_service.dart';
import 'add_edit_fuel_screen.dart';
import 'add_expense_screen.dart';
import 'add_edit_maintenance_screen.dart';
import '../widgets/main_drawer.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionsService _service = TransactionsService.instance;
  
  List<TransactionRecord> _records = [];
  List<Truck> _trucks = [];
  bool _isLoading = true;

  // Filters
  TransactionType? _activeType; // null means 'All'
  int? _selectedTruckId;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final trucks = await TruckService.instance.getAllTrucks();
    setState(() {
      _trucks = trucks;
    });
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final results = await _service.getAllTransactions(
      truckId: _selectedTruckId,
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
      searchTerm: _searchController.text.trim(),
      filterType: _activeType,
    );
    setState(() {
      _records = results;
      _isLoading = false;
    });
  }

  void _showAddSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'What do you want to add?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.local_gas_station, color: Colors.white),
                  ),
                  title: const Text('Fuel Entry'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditFuelScreen()),
                    ).then((result) {
                      if (result == true) _loadTransactions();
                    });
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: const Text('General Expense'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    ).then((result) {
                      if (result == true) _loadTransactions();
                    });
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.build, color: Colors.white),
                  ),
                  title: const Text('Maintenance Record'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditMaintenanceScreen()),
                    ).then((result) {
                      if (result == true) _loadTransactions();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadTransactions();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTruckId = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    _loadTransactions();
  }

  void _onRecordTap(TransactionRecord record) {
    Widget screen;
    switch (record.type) {
      case TransactionType.fuel:
        screen = AddEditFuelScreen(fuelEntry: record.originalRecord as FuelEntry);
        break;
      case TransactionType.expense:
        screen = AddExpenseScreen(expense: record.originalRecord as Map<String, dynamic>);
        break;
      case TransactionType.maintenance:
        screen = AddEditMaintenanceScreen(maintenanceEntry: record.originalRecord as MaintenanceEntry);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((result) {
      if (result == true) _loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _loadTransactions, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: const MainDrawer(selectedIndex: 2),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildTypeFilterChips(),
          if (_startDate != null) _buildDateSummary(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionCard(_records[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSelection,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => _loadTransactions(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  key: ValueKey('truck_filter_$_selectedTruckId'),
                  isExpanded: true,
                  initialValue: _selectedTruckId,
                  decoration: InputDecoration(
                    labelText: 'Truck',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Trucks')),
                    ..._trucks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.truckNumber, overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTruckId = val);
                    _loadTransactions();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                tooltip: 'Date Filter',
              ),
              if (_selectedTruckId != null || _startDate != null || _searchController.text.isNotEmpty)
                IconButton.outlined(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear Filters',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _buildTypeChip('All', null),
          _buildTypeChip('Fuel', TransactionType.fuel),
          _buildTypeChip('Expense', TransactionType.expense),
          _buildTypeChip('Maintenance', TransactionType.maintenance),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, TransactionType? type) {
    final isSelected = _activeType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() => _activeType = type);
          _loadTransactions();
        },
      ),
    );
  }

  Widget _buildDateSummary() {
    final df = DateFormat('dd MMM yy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '${df.format(_startDate!)} to ${df.format(_endDate!)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No transactions found.', style: TextStyle(color: Colors.grey, fontSize: 18)),
          if (_selectedTruckId != null || _startDate != null || _searchController.text.isNotEmpty || _activeType != null)
            TextButton(onPressed: _clearFilters, child: const Text('Clear all filters')),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionRecord record) {
    Color typeColor;
    IconData icon;
    String typeLabel;

    switch (record.type) {
      case TransactionType.fuel:
        typeColor = Colors.orange;
        icon = Icons.local_gas_station;
        typeLabel = 'Fuel';
        break;
      case TransactionType.expense:
        typeColor = Colors.blue;
        icon = Icons.payments;
        typeLabel = 'Expense';
        break;
      case TransactionType.maintenance:
        typeColor = Colors.brown;
        icon = Icons.build;
        typeLabel = 'Maint.';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () => _onRecordTap(record),
        leading: CircleAvatar(
          backgroundColor: typeColor.withAlpha(25),
          child: Icon(icon, color: typeColor, size: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(record.truckNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '₹${record.amount.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(typeLabel, style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(record.date, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              record.description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }
}
