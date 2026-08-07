import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';
import 'add_edit_driver_screen.dart';

class DriverMasterScreen extends StatefulWidget {
  const DriverMasterScreen({super.key});

  @override
  State<DriverMasterScreen> createState() => _DriverMasterScreenState();
}

class _DriverMasterScreenState extends State<DriverMasterScreen> {
  List<Driver> drivers = [];
  List<Driver> filteredDrivers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    try {
      final data = await DriverService.instance.getAllDrivers();
      setState(() {
        drivers = data;
        filteredDrivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load drivers: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredDrivers = drivers.where((driver) {
        return driver.driverName.toLowerCase().contains(query) ||
            (driver.mobileNumber?.toLowerCase().contains(query) ?? false) ||
            (driver.licenseNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _navigateToAddEdit([Driver? driver]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditDriverScreen(driver: driver),
      ),
    );
    if (result == true) {
      _loadDrivers();
    }
  }

  Future<void> _deleteDriver(Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Driver?'),
        content: Text('Are you sure you want to delete ${driver.driverName}?'),
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
      final result = await DriverService.instance.deleteDriver(driver.id!);
      if (result == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete driver used in expenses')),
        );
      } else {
        _loadDrivers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Master"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search drivers...',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDrivers.isEmpty
                    ? const Center(child: Text('No drivers found.'))
                    : ListView.builder(
                        itemCount: filteredDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = filteredDrivers[index];
                          return _buildDriverCard(driver);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        tooltip: 'Add Driver',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          driver.driverName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driver.mobileNumber != null && driver.mobileNumber!.isNotEmpty)
              Text('Mobile: ${driver.mobileNumber}'),
            if (driver.licenseNumber != null && driver.licenseNumber!.isNotEmpty)
              Text('License: ${driver.licenseNumber}'),
            const SizedBox(height: 4),
            _statusBadge(driver.status),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToAddEdit(driver);
            } else if (value == 'delete') {
              _deleteDriver(driver);
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
      case 'Terminated':
        color = Colors.red;
        break;
      case 'On Leave':
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
