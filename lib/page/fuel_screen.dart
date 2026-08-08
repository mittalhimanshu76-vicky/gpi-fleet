import 'package:flutter/material.dart';
import '../models/fuel_entry.dart';
import '../models/truck.dart';
import '../services/fuel_service.dart';
import '../services/truck_service.dart';
import 'add_edit_fuel_screen.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  List<FuelEntry> _entries = [];
  List<Truck> _trucks = [];
  int? _selectedTruckId;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

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
    await _loadFuelEntries();
  }

  Future<void> _loadFuelEntries() async {
    setState(() => _isLoading = true);
    final entries = await FuelService.instance.filterFuelEntries(
      truckId: _selectedTruckId,
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
      searchTerm: _searchController.text.trim(),
    );
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
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
      _loadFuelEntries();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTruckId = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    _loadFuelEntries();
  }

  Future<void> _navigateToAddEdit([FuelEntry? entry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditFuelScreen(fuelEntry: entry)),
    );
    if (result == true) {
      _loadFuelEntries();
    }
  }

  Future<void> _deleteEntry(FuelEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('Are you sure you want to delete this fuel entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FuelService.instance.deleteFuelEntry(entry.id!);
      _loadFuelEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Management'),
        actions: [
          IconButton(onPressed: _loadFuelEntries, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildActiveFiltersSummary(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return _buildFuelCard(entry);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Fuel'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search fuel entries...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => _loadFuelEntries(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: _selectedTruckId,
                  decoration: InputDecoration(
                    labelText: 'Truck',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Trucks')),
                    ..._trucks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.truckNumber))),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTruckId = val);
                    _loadFuelEntries();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                tooltip: 'Filter by Date',
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

  Widget _buildActiveFiltersSummary() {
    if (_startDate == null && _endDate == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            '${_startDate!.toIso8601String().split('T')[0]} to ${_endDate!.toIso8601String().split('T')[0]}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          const Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No fuel entries found.', style: TextStyle(color: Colors.grey, fontSize: 18)),
          if (_selectedTruckId != null || _startDate != null || _searchController.text.isNotEmpty)
            TextButton(onPressed: _clearFilters, child: const Text('Clear all filters')),
        ],
      ),
    );
  }

  Widget _buildFuelCard(FuelEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              entry.truckNumber ?? 'Unknown Truck',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '₹${entry.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(entry.date, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.speed, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${entry.odometer?.toStringAsFixed(0) ?? '--'} km', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.liters.toStringAsFixed(2)} L @ ₹${entry.ratePerLiter?.toStringAsFixed(2) ?? '--'}/L',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (entry.fuelStation != null && entry.fuelStation!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Station: ${entry.fuelStation}',
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            if (val == 'edit') _navigateToAddEdit(entry);
            if (val == 'delete') _deleteEntry(entry);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }
}
