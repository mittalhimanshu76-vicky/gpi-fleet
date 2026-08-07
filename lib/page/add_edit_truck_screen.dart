import 'package:flutter/material.dart';
import '../services/truck_service.dart';
import '../models/truck.dart';

class AddEditTruckScreen extends StatefulWidget {
  final Truck? truck;

  const AddEditTruckScreen({super.key, this.truck});

  @override
  State<AddEditTruckScreen> createState() => _AddEditTruckScreenState();
}

class _AddEditTruckScreenState extends State<AddEditTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _truckNumberController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _ownerNameController;
  late TextEditingController _remarksController;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _truckNumberController =
        TextEditingController(text: widget.truck?.truckNumber ?? '');
    _registrationNumberController =
        TextEditingController(text: widget.truck?.registrationNumber ?? '');
    _vehicleTypeController =
        TextEditingController(text: widget.truck?.vehicleType ?? '');
    _makeController = TextEditingController(text: widget.truck?.make ?? '');
    _modelController = TextEditingController(text: widget.truck?.model ?? '');
    _ownerNameController =
        TextEditingController(text: widget.truck?.ownerName ?? '');
    _remarksController = TextEditingController(text: widget.truck?.remarks ?? '');
    _status = widget.truck?.status ?? 'Active';
  }

  @override
  void dispose() {
    _truckNumberController.dispose();
    _registrationNumberController.dispose();
    _vehicleTypeController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _ownerNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final truck = Truck(
      id: widget.truck?.id,
      truckNumber: _truckNumberController.text.trim().toUpperCase(),
      registrationNumber: _registrationNumberController.text.trim().toUpperCase(),
      vehicleType: _vehicleTypeController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      status: _status,
      remarks: _remarksController.text.trim(),
    );

    try {
      if (widget.truck == null) {
        await TruckService.instance.addTruck(truck);
      } else {
        await TruckService.instance.updateTruck(truck);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().contains('UNIQUE') ? 'Truck number already exists' : 'Failed to save truck'}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.truck == null ? 'Add Truck' : 'Edit Truck'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _truckNumberController,
                decoration: const InputDecoration(
                  labelText: 'Truck Number *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. MH12AB1234',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter truck number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationNumberController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Make',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.truck == null ? 'Save Truck' : 'Update Truck'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
