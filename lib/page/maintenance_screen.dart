import 'package:flutter/material.dart';
import '../models/maintenance_entry.dart';
import '../models/truck.dart';
import '../services/maintenance_service.dart';
import '../services/truck_service.dart';
import 'add_edit_maintenance_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<MaintenanceEntry> _entries = [];
  List<Truck> _trucks = [];
  int? _selectedTruckId;
  String _selectedType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final List<String> _types = [
    'All',
    'Routine Service',
    'Engine',
    'Tyres',
    'Brakes',
    'Suspension',
    'Electrical',
    'Battery',
    'AC',
    'Body Repair',
    'Accident Repair',
    'Other',
  ];

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
    await _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await MaintenanceService.instance.getAllMaintenanceEntries(
      truckId: _selectedTruckId,
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
      type: _selectedType,
      searchTerm: _searchController.text.trim(),
    );
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
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
      _loadEntries();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTruckId = null;
      _selectedType = 'All';
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    _loadEntries();
  }

  Future<void> _navigateToAddEdit([MaintenanceEntry? entry]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditMaintenanceScreen(maintenanceEntry: entry)),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _deleteEntry(MaintenanceEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Entry?'),
        content: const Text('Are you sure you want to delete this maintenance entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MaintenanceService.instance.deleteMaintenanceEntry(entry.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintenance entry deleted.')),
        );
      }
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        actions: [
          IconButton(onPressed: _loadEntries, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndFilters(),
          if (_startDate != null) _buildDateRangeSummary(),
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
                          return _buildMaintenanceCard(entry);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search maintenance...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => _loadEntries(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 150),
                child: DropdownButtonFormField<int?>(
                  isExpanded: true,
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
                    _loadEntries();
                  },
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 150),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedType = val!);
                    _loadEntries();
                  },
                ),
              ),
              IconButton.filledTonal(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                tooltip: 'Filter by Date',
              ),
              if (_selectedTruckId != null || _selectedType != 'All' || _startDate != null || _searchController.text.isNotEmpty)
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

  Widget _buildDateRangeSummary() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${_startDate!.toIso8601String().split('T')[0]} to ${_endDate!.toIso8601String().split('T')[0]}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
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
          const Icon(Icons.build_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No maintenance records found.', style: TextStyle(color: Colors.grey, fontSize: 18)),
          if (_selectedTruckId != null || _selectedType != 'All' || _startDate != null || _searchController.text.isNotEmpty)
            TextButton(onPressed: _clearFilters, child: const Text('Clear all filters')),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _navigateToAddEdit(entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.truckNumber ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.maintenanceType,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(entry.date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${entry.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToAddEdit(entry);
                            } else if (value == 'delete') {
                              _deleteEntry(entry);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildMiniInfo(Icons.speed, '${entry.odometer?.toStringAsFixed(0) ?? '--'} km'),
                  if (entry.serviceProvider != null && entry.serviceProvider!.isNotEmpty)
                    _buildMiniInfo(Icons.home_repair_service, entry.serviceProvider!),
                  if (entry.nextServiceDate != null)
                    _buildMiniInfo(Icons.event_repeat, 'Next: ${entry.nextServiceDate}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
