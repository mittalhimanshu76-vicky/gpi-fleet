import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';

class AddEditDriverScreen extends StatefulWidget {
  final Driver? driver;

  const AddEditDriverScreen({super.key, this.driver});

  @override
  State<AddEditDriverScreen> createState() => _AddEditDriverScreenState();
}

class _AddEditDriverScreenState extends State<AddEditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _licenseController;
  late TextEditingController _expiryController;
  late TextEditingController _joiningController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyController;
  late TextEditingController _aadhaarController;
  late TextEditingController _remarksController;
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.driverName ?? '');
    _mobileController = TextEditingController(text: widget.driver?.mobileNumber ?? '');
    _licenseController = TextEditingController(text: widget.driver?.licenseNumber ?? '');
    _expiryController = TextEditingController(text: widget.driver?.licenseExpiry ?? '');
    _joiningController = TextEditingController(text: widget.driver?.joiningDate ?? '');
    _addressController = TextEditingController(text: widget.driver?.address ?? '');
    _emergencyController = TextEditingController(text: widget.driver?.emergencyContact ?? '');
    _aadhaarController = TextEditingController(text: widget.driver?.aadhaarNumber ?? '');
    _remarksController = TextEditingController(text: widget.driver?.remarks ?? '');
    _status = widget.driver?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _licenseController.dispose();
    _expiryController.dispose();
    _joiningController.dispose();
    _addressController.dispose();
    _emergencyController.dispose();
    _aadhaarController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final driver = Driver(
      id: widget.driver?.id,
      driverName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
      licenseExpiry: _expiryController.text.trim(),
      joiningDate: _joiningController.text.trim(),
      address: _addressController.text.trim(),
      emergencyContact: _emergencyController.text.trim(),
      aadhaarNumber: _aadhaarController.text.trim(),
      status: _status,
      remarks: _remarksController.text.trim(),
    );

    try {
      if (widget.driver == null) {
        await DriverService.instance.addDriver(driver);
      } else {
        await DriverService.instance.updateDriver(driver);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save driver: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driver == null ? 'Add Driver' : 'Edit Driver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter driver name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'License Expiry',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _pickDate(_expiryController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _joiningController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Joining Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(_joiningController),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
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
                  DropdownMenuItem(value: 'On Leave', child: Text('On Leave')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'Terminated', child: Text('Terminated')),
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
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.driver == null ? 'SAVE DRIVER' : 'UPDATE DRIVER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
