import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DriverMasterScreen extends StatefulWidget {
  const DriverMasterScreen({super.key});

  @override
  State<DriverMasterScreen> createState() => _DriverMasterScreenState();
}

class _DriverMasterScreenState extends State<DriverMasterScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> drivers = [];

  @override
  void initState() {
    super.initState();
    loadDrivers();
  }

  Future<void> loadDrivers() async {
    drivers = await DatabaseHelper.instance.getDrivers();
    setState(() {});
  }

  Future<void> addDriver() async {
    if (controller.text.trim().isEmpty) return;

    await DatabaseHelper.instance.addDriver(
      controller.text.trim(),
    );

    controller.clear();

    loadDrivers();
  }

  Future<void> deleteDriver(int id) async {
    if (await DatabaseHelper.instance.isDriverReferenced(id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete a driver used by expenses')),
      );
      return;
    }

    await DatabaseHelper.instance.deleteDriver(id);

    loadDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Master"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Driver Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addDriver,
                child: const Text("Add Driver"),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(drivers[index]["name"]),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          deleteDriver(
                            drivers[index]["id"],
                          );
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
