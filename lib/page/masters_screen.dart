import 'package:flutter/material.dart';
import 'driver_master_screen.dart';
import 'truck_master_screen.dart';

class MastersScreen extends StatelessWidget {
  const MastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masters"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text(
                  "Driver Master",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverMasterScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_shipping),
                label: const Text(
                  "Truck Master",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TruckMasterScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}