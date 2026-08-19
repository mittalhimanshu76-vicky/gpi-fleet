import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'truck_master_screen.dart';
import 'driver_master_screen.dart';
import 'fuel_screen.dart';
import 'history_screen.dart';
import 'maintenance_screen.dart';
import 'reports_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TruckMasterScreen(),
    const DriverMasterScreen(),
    const Center(child: Text('All Transactions (Coming Soon)')),
    const FuelScreen(),
    const ExpenseHistoryScreen(),
    const MaintenanceScreen(),
    const ReportsScreen(),
    const MoreScreen(),
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onSelectItem,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 16, 10),
            child: Row(
              children: [
                Image.asset('assets/image/gpi_logo.png', height: 40, errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_shipping, size: 40, color: Colors.green)),
                const SizedBox(width: 12),
                const Text(
                  'GPI Fleet',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Fleet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: Text('Trucks'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Drivers'),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Text('All'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station),
            label: Text('Fuel'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: Text('Expense'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: Text('Maintenance'),
          ),

          const Divider(indent: 28, endIndent: 28),
          const NavigationDrawerDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Reports'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
