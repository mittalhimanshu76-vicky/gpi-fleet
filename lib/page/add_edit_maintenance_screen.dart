import 'package:flutter/material.dart';
import '../models/maintenance_entry.dart';
import '../models/truck.dart';
import '../services/maintenance_service.dart';
import '../services/truck_service.dart';

class AddEditMaintenanceScreen extends StatefulWidget {
  final MaintenanceEntry? maintenanceEntry;

  const AddEditMaintenanceScreen({super.key, this.maintenanceEntry});

  @override
  State<AddEditMaintenanceScreen> createState() => _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState extends State<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _odometerController;
  late TextEditingController _amountController;
  late TextEditingController _serviceProviderController;
  late TextEditingController _nextOdometerController;
  late TextEditingController _remarksController;
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;
  int? _selectedTruckId;
  String? _selectedType;
  String _paymentMode = 'Cash';
  List<Truck> _trucks = [];
  bool _isLoadingTrucks = true;

  final List<String> _maintenanceTypes = [
    'Routine Service',
    'Engine',
    'Tyres',
    'Brakes',
    'Suspension',
    'Electrical',
    'Battery',
    'AC',
    'Body Repair',
    'Accident Repair',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.maintenanceEntry?.description ?? '');
    _odometerController = TextEditingController(text: widget.maintenanceEntry?.odometer?.toString() ?? '');
    _amountController = TextEditingController(text: widget.maintenanceEntry?.amount.toString() ?? '');
    _serviceProviderController = TextEditingController(text: widget.maintenanceEntry?.serviceProvider ?? '');
    _nextOdometerController = TextEditingController(text: widget.maintenanceEntry?.nextServiceOdometer?.toString() ?? '');
    _remarksController = TextEditingController(text: widget.maintenanceEntry?.remarks ?? '');
    
    if (widget.maintenanceEntry != null) {
      _selectedDate = DateTime.parse(widget.maintenanceEntry!.date);
      _selectedTruckId = widget.maintenanceEntry!.truckId;
      _selectedType = widget.maintenanceEntry!.maintenanceType;
      _paymentMode = widget.maintenanceEntry!.paymentMode ?? 'Cash';
      if (widget.maintenanceEntry!.nextServiceDate != null) {
        _nextServiceDate = DateTime.parse(widget.maintenanceEntry!.nextServiceDate!);
      }
    }

    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    final trucks = await TruckService.instance.getActiveTrucks();
    setState(() {
      _trucks = trucks;
      _isLoadingTrucks = false;
      
      if (widget.maintenanceEntry != null && !_trucks.any((t) => t.id == widget.maintenanceEntry!.truckId)) {
        _loadSpecificTruck(widget.maintenanceEntry!.truckId);
      }
    });
  }

  Future<void> _loadSpecificTruck(int id) async {
    final truck = await TruckService.instance.getTruck(id);
    if (truck != null && mounted) {
      setState(() {
        _trucks.add(truck);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _odometerController.dispose();
    _amountController.dispose();
    _serviceProviderController.dispose();
    _nextOdometerController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isNext) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isNext ? (_nextServiceDate ?? DateTime.now().add(const Duration(days: 90))) : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isNext) {
          _nextServiceDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTruckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a truck')));
      return;
    }
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select maintenance type')));
      return;
    }

    final entry = MaintenanceEntry(
      id: widget.maintenanceEntry?.id,
      truckId: _selectedTruckId!,
      date: _selectedDate.toIso8601String().split('T')[0],
      maintenanceType: _selectedType!,
      description: _descriptionController.text.trim(),
      odometer: double.tryParse(_odometerController.text),
      amount: double.parse(_amountController.text),
      serviceProvider: _serviceProviderController.text.trim(),
      nextServiceDate: _nextServiceDate?.toIso8601String().split('T')[0],
      nextServiceOdometer: double.tryParse(_nextOdometerController.text),
      paymentMode: _paymentMode,
      remarks: _remarksController.text.trim(),
      createdAt: widget.maintenanceEntry?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      if (widget.maintenanceEntry == null) {
        await MaintenanceService.instance.addMaintenanceEntry(entry);
      } else {
        await MaintenanceService.instance.updateMaintenanceEntry(entry);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.maintenanceEntry == null ? 'Add Maintenance' : 'Edit Maintenance'),
      ),
      body: _isLoadingTrucks 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Vehicle & Date'),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedTruckId,
                    decoration: const InputDecoration(
                      labelText: 'Truck *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                    items: _trucks.map((t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.truckNumber),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedTruckId = val),
                    validator: (val) => val == null ? 'Select truck' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(text: _selectedDate.toIso8601String().split('T')[0]),
                          decoration: InputDecoration(
                            labelText: 'Date *',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _pickDate(false),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _odometerController,
                          decoration: const InputDecoration(
                            labelText: 'Odometer',
                            border: OutlineInputBorder(),
                            suffixText: 'km',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Service Details'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Maintenance Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: _maintenanceTypes.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedType = val),
                    validator: (val) => val == null ? 'Select type' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'What was fixed?',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                        return 'Amount > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serviceProviderController,
                    decoration: const InputDecoration(
                      labelText: 'Service Provider / Workshop',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home_repair_service),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Next Service Plan'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _nextServiceDate != null ? _nextServiceDate!.toIso8601String().split('T')[0] : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Next Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () => _pickDate(true),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _nextOdometerController,
                          decoration: const InputDecoration(
                            labelText: 'Next Odometer',
                            border: OutlineInputBorder(),
                            suffixText: 'km',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment & Remarks'),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                    ],
                    onChanged: (val) => setState(() => _paymentMode = val!),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        widget.maintenanceEntry == null ? 'SAVE MAINTENANCE' : 'UPDATE MAINTENANCE',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
