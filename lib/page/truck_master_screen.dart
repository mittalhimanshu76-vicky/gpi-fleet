import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class TruckMasterScreen extends StatefulWidget {
  const TruckMasterScreen({super.key});

  @override
  State<TruckMasterScreen> createState() => _TruckMasterScreenState();
}

class _TruckMasterScreenState extends State<TruckMasterScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> trucks = [];

  @override
  void initState() {
    super.initState();
    loadTrucks();
  }

  Future<void> loadTrucks() async {
    trucks = await DatabaseHelper.instance.getTrucks();
    setState(() {});
  }

  Future<void> addTruck() async {
    if (controller.text.trim().isEmpty) return;

    await DatabaseHelper.instance.addTruck(
      controller.text.trim().toUpperCase(),
    );

    controller.clear();

    loadTrucks();
  }

  Future<void> deleteTruck(int id) async {
    if (await DatabaseHelper.instance.isTruckReferenced(id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete a truck used by expenses')),
      );
      return;
    }

    await DatabaseHelper.instance.deleteTruck(id);

    loadTrucks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Truck Master"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Truck Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addTruck,
                child: const Text("Add Truck"),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: trucks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_shipping),
                      title: Text(trucks[index]["truck_no"]),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          deleteTruck(trucks[index]["id"]);
                        },
                      ),
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
