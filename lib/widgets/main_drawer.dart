import 'package:flutter/material.dart';
import '../page/home_screen.dart';
import '../page/fleet_screen.dart';
import '../page/transactions_screen.dart';
import '../page/reports_screen.dart';
import '../page/more_screen.dart';

class MainDrawer extends StatelessWidget {
  final int selectedIndex;
  const MainDrawer({super.key, required this.selectedIndex});

  void _onSelectItem(BuildContext context, int index, Widget screen) {
    if (selectedIndex == index) {
      Navigator.pop(context);
      return;
    }
    
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            _onSelectItem(context, 0, const HomeScreen());
            break;
          case 1:
            _onSelectItem(context, 1, const FleetScreen());
            break;
          case 2:
            _onSelectItem(context, 2, const TransactionsScreen());
            break;
          case 3:
            _onSelectItem(context, 3, const ReportsScreen());
            break;
          case 4:
            _onSelectItem(context, 4, const MoreScreen());
            break;
        }
      },
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
        
        const NavigationDrawerDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping),
          label: Text('Fleet'),
        ),

        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: Text('Transactions'),
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
    );
  }
}
