import 'package:flutter/material.dart';
import '../services/truck_service.dart';
import '../models/truck.dart';
import 'add_edit_truck_screen.dart';

class TruckMasterScreen extends StatefulWidget {
  const TruckMasterScreen({super.key});

  @override
  State<TruckMasterScreen> createState() => _TruckMasterScreenState();
}

class _TruckMasterScreenState extends State<TruckMasterScreen> {
  List<Truck> trucks = [];
  List<Truck> filteredTrucks = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrucks() async {
    setState(() => _isLoading = true);
    try {
      final data = await TruckService.instance.getAllTrucks();
      setState(() {
        trucks = data;
        filteredTrucks = trucks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load trucks')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTrucks = trucks.where((truck) {
        return truck.truckNumber.toLowerCase().contains(query) ||
            (truck.registrationNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _navigateToAddEdit([Truck? truck]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTruckScreen(truck: truck),
      ),
    );
    if (result == true) {
      _loadTrucks();
    }
  }

  Future<void> _deleteTruck(Truck truck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Truck?'),
        content: Text('Are you sure you want to delete ${truck.truckNumber}?'),
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
      final result = await TruckService.instance.deleteTruck(truck.id!);
      if (result == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete truck used in expenses')),
        );
      } else {
        _loadTrucks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Truck Master"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search trucks...',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTrucks.isEmpty
                    ? const Center(child: Text('No trucks found.'))
                    : ListView.builder(
                        itemCount: filteredTrucks.length,
                        itemBuilder: (context, index) {
                          final truck = filteredTrucks[index];
                          return _buildTruckCard(truck);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        tooltip: 'Add Truck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTruckCard(Truck truck) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.local_shipping,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          truck.truckNumber,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (truck.registrationNumber != null && truck.registrationNumber!.isNotEmpty)
              Text('Reg No: ${truck.registrationNumber}'),
            if (truck.vehicleType != null && truck.vehicleType!.isNotEmpty)
              Text('Type: ${truck.vehicleType}'),
            const SizedBox(height: 4),
            _statusBadge(truck.status),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToAddEdit(truck);
            } else if (value == 'delete') {
              _deleteTruck(truck);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'Inactive':
        color = Colors.red;
        break;
      case 'Maintenance':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
