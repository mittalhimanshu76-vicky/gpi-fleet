import 'package:flutter/material.dart';
import '../models/fuel_entry.dart';
import '../models/truck.dart';
import '../services/fuel_service.dart';
import '../services/truck_service.dart';

class AddEditFuelScreen extends StatefulWidget {
  final FuelEntry? fuelEntry;

  const AddEditFuelScreen({super.key, this.fuelEntry});

  @override
  State<AddEditFuelScreen> createState() => _AddEditFuelScreenState();
}

class _AddEditFuelScreenState extends State<AddEditFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _odometerController;
  late TextEditingController _litersController;
  late TextEditingController _rateController;
  late TextEditingController _totalController;
  late TextEditingController _stationController;
  late TextEditingController _remarksController;
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedTruckId;
  String _paymentMode = 'Cash';
  List<Truck> _trucks = [];
  bool _isLoadingTrucks = true;

  @override
  void initState() {
    super.initState();
    _odometerController = TextEditingController(text: widget.fuelEntry?.odometer?.toString() ?? '');
    _litersController = TextEditingController(text: widget.fuelEntry?.liters.toString() ?? '');
    _rateController = TextEditingController(text: widget.fuelEntry?.ratePerLiter?.toString() ?? '');
    _totalController = TextEditingController(text: widget.fuelEntry?.totalAmount.toString() ?? '');
    _stationController = TextEditingController(text: widget.fuelEntry?.fuelStation ?? '');
    _remarksController = TextEditingController(text: widget.fuelEntry?.remarks ?? '');
    
    if (widget.fuelEntry != null) {
      _selectedDate = DateTime.parse(widget.fuelEntry!.date);
      _selectedTruckId = widget.fuelEntry!.truckId;
      _paymentMode = widget.fuelEntry!.paymentMode ?? 'Cash';
    }

    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    // Load only ACTIVE trucks as per requirement
    final trucks = await TruckService.instance.getActiveTrucks();
    setState(() {
      _trucks = trucks;
      _isLoadingTrucks = false;
      
      // If editing and the truck is not active, we still need to show it in the list
      if (widget.fuelEntry != null && !_trucks.any((t) => t.id == widget.fuelEntry!.truckId)) {
        _loadSpecificTruck(widget.fuelEntry!.truckId);
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
    _odometerController.dispose();
    _litersController.dispose();
    _rateController.dispose();
    _totalController.dispose();
    _stationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final liters = double.tryParse(_litersController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    if (liters > 0 && rate > 0) {
      setState(() {
        _totalController.text = (liters * rate).toStringAsFixed(2);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTruckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a truck')));
      return;
    }

    final entry = FuelEntry(
      id: widget.fuelEntry?.id,
      truckId: _selectedTruckId!,
      date: _selectedDate.toIso8601String().split('T')[0],
      odometer: double.tryParse(_odometerController.text),
      liters: double.parse(_litersController.text),
      ratePerLiter: double.tryParse(_rateController.text),
      totalAmount: double.parse(_totalController.text),
      fuelStation: _stationController.text.trim(),
      paymentMode: _paymentMode,
      remarks: _remarksController.text.trim(),
      createdAt: widget.fuelEntry?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      if (widget.fuelEntry == null) {
        await FuelService.instance.addFuelEntry(entry);
      } else {
        await FuelService.instance.updateFuelEntry(entry);
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
        title: Text(widget.fuelEntry == null ? 'Add Fuel Entry' : 'Edit Fuel Entry'),
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
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(text: _selectedDate.toIso8601String().split('T')[0]),
                    decoration: InputDecoration(
                      labelText: 'Date *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Date required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(
                      labelText: 'Odometer Reading',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Fuel Details'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _litersController,
                          decoration: const InputDecoration(
                            labelText: 'Liters *',
                            border: OutlineInputBorder(),
                            suffixText: 'L',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _calculateTotal(),
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                              return 'Liters > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          decoration: const InputDecoration(
                            labelText: 'Rate/Liter',
                            border: OutlineInputBorder(),
                            prefixText: '₹',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _calculateTotal(),
                          validator: (val) {
                            if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
                              return 'Invalid rate';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _totalController,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount *',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                      hintText: 'Auto-calculated or manual',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                        return 'Total > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Optional Info'),
                  TextFormField(
                    controller: _stationController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Station',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_gas_station),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(value: 'Fuel Card', child: Text('Fuel Card')),
                      DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
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
                        widget.fuelEntry == null ? 'SAVE FUEL ENTRY' : 'UPDATE FUEL ENTRY',
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
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
