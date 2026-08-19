import 'package:flutter/material.dart';
import '../services/truck_service.dart';
import '../services/driver_service.dart';
import 'truck_master_screen.dart';
import 'driver_master_screen.dart';
import '../widgets/main_drawer.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  int _truckCount = 0;
  int _driverCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    try {
      final trucks = await TruckService.instance.getAllTrucks();
      final drivers = await DriverService.instance.getAllDrivers();
      setState(() {
        _truckCount = trucks.length;
        _driverCount = drivers.length;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: const MainDrawer(selectedIndex: 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHubCard(
                    context,
                    title: 'Trucks',
                    subtitle: '$_truckCount registered vehicles',
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TruckMasterScreen()),
                    ).then((_) => _loadCounts()),
                  ),
                  const SizedBox(height: 16),
                  _buildHubCard(
                    context,
                    title: 'Drivers',
                    subtitle: '$_driverCount registered personnel',
                    icon: Icons.person,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DriverMasterScreen()),
                    ).then((_) => _loadCounts()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
