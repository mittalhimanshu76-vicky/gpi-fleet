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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final trucks = await TruckService.instance.getAllTrucks();
    final entries = await FuelService.instance.getFuelEntries(truckId: _selectedTruckId);
    setState(() {
      _trucks = trucks;
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddEdit([FuelEntry? entry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditFuelScreen(fuelEntry: entry)),
    );
    if (result == true) {
      _loadData();
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
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Management'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int?>(
              value: _selectedTruckId,
              decoration: const InputDecoration(
                labelText: 'Filter by Truck',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Trucks')),
                ..._trucks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.truckNumber))),
              ],
              onChanged: (val) {
                setState(() => _selectedTruckId = val);
                _loadData();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const Center(child: Text('No fuel entries found.'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return _buildFuelCard(entry);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFuelCard(FuelEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entry.truckNumber ?? 'Unknown Truck', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('₹${entry.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(entry.date),
                const SizedBox(width: 12),
                const Icon(Icons.speed, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${entry.odometer ?? '--'} km'),
              ],
            ),
            const SizedBox(height: 4),
            Text('${entry.liters} L @ ₹${entry.ratePerLiter ?? '--'}/L'),
            if (entry.fuelStation != null && entry.fuelStation!.isNotEmpty)
              Text('Station: ${entry.fuelStation}', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') _navigateToAddEdit(entry);
            if (val == 'delete') _deleteEntry(entry);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
