import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/truck.dart';
import '../models/report_summary.dart';
import '../services/reports_service.dart';
import '../services/truck_service.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../services/share_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  int? _selectedTruckId;
  List<Truck> _trucks = [];
  late Future<ReportSummary> _reportFuture;
  bool _isExporting = false;
  ReportSummary? _lastReport;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final trucks = await TruckService.instance.getAllTrucks();
    setState(() {
      _trucks = trucks;
    });
    _loadReport();
  }

  void _loadReport() {
    setState(() {
      _reportFuture = ReportsService.instance.getFleetOperatingReport(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _loadReport();
    }
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    });
    _loadReport();
  }

  void _setLastMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month - 1, 1);
      _endDate = DateTime(now.year, now.month, 0);
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operating Cost Reports'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDateFilters(),
          Expanded(
            child: FutureBuilder<ReportSummary>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        TextButton(onPressed: _loadReport, child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                final report = snapshot.data!;

                // Apply truck filter if selected
                ReportSummary displayReport = report;
                TruckCostSummary? selectedTruckSummary;

                if (_selectedTruckId != null) {
                  try {
                    selectedTruckSummary = report.truckCosts.firstWhere((tc) => tc.truckId == _selectedTruckId);
                    displayReport = ReportSummary(
                      startDate: report.startDate,
                      endDate: report.endDate,
                      expenseTotal: selectedTruckSummary.expenseTotal,
                      fuelTotal: selectedTruckSummary.fuelTotal,
                      maintenanceTotal: selectedTruckSummary.maintenanceTotal,
                      operatingCostTotal: selectedTruckSummary.operatingCostTotal,
                      truckCosts: [selectedTruckSummary],
                    );
                  } catch (_) {
                    // Selected truck has no data in this period
                    displayReport = ReportSummary(
                      startDate: report.startDate,
                      endDate: report.endDate,
                      expenseTotal: 0,
                      fuelTotal: 0,
                      maintenanceTotal: 0,
                      operatingCostTotal: 0,
                      truckCosts: [],
                    );
                  }
                }

                _lastReport = displayReport;

                if (displayReport.truckCosts.isEmpty && _selectedTruckId == null) {
                  return const Center(child: Text('No transactions found for this period.'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadReport(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(displayReport, selectedTruckSummary),
                        const SizedBox(height: 16),
                        _buildExportSection(),
                        const SizedBox(height: 24),
                        Text(
                          _selectedTruckId == null ? 'Truck-wise Breakdown' : 'Operating Details',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (displayReport.truckCosts.isEmpty)
                          const Center(child: Text('No transactions for this truck in this period.'))
                        else
                          ...displayReport.truckCosts.map((tc) => _buildTruckCostCard(tc)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    final df = DateFormat('yyyy-MM-dd');
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface.withAlpha(25),
      child: Column(
        children: [
          DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: _selectedTruckId,
            decoration: InputDecoration(
              labelText: 'Select Truck',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.local_shipping),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Trucks')),
              ..._trucks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.truckNumber))),
            ],
            onChanged: (val) {
              setState(() => _selectedTruckId = val);
              _loadReport();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('From: ${df.format(_startDate)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context, false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('To: ${df.format(_endDate)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionChip(
                label: const Text('This Month'),
                onPressed: _setThisMonth,
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Last Month'),
                onPressed: _setLastMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ReportSummary report, [TruckCostSummary? selectedTruck]) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('Expenses', report.expenseTotal, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard('Fuel', report.fuelTotal, Colors.orange),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              selectedTruck != null ? 'Maintenance Cost' : 'Maintenance',
              report.maintenanceTotal,
              Colors.brown,
            ),
            const SizedBox(width: 12),
            _buildStatCard('Total Cost', report.operatingCostTotal, Colors.green, isPrimary: true),
          ],
        ),
        if (selectedTruck != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 1,
                  color: Colors.brown.withAlpha(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maintenance Events',
                          style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedTruck.maintenanceCount}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, double amount, Color color, {bool isPrimary = false}) {
    return Expanded(
      child: Card(
        elevation: isPrimary ? 4 : 1,
        color: isPrimary ? color : color.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isPrimary ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTruckCostCard(TruckCostSummary tc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tc.truckNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₹${tc.operatingCostTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallInfo('Exp: ₹${tc.expenseTotal.toStringAsFixed(0)}'),
                _buildSmallInfo('Fuel: ₹${tc.fuelTotal.toStringAsFixed(0)}'),
                _buildSmallInfo('Maint: ₹${tc.maintenanceTotal.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Report',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildExportButton(
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              color: Colors.red.shade700,
              onTap: () => _handleExport('pdf'),
            ),
            const SizedBox(width: 8),
            _buildExportButton(
              icon: Icons.table_chart,
              label: 'Excel',
              color: Colors.green.shade700,
              onTap: () => _handleExport('excel'),
            ),
            const SizedBox(width: 8),
            _buildExportButton(
              icon: Icons.share,
              label: 'Share',
              color: Colors.blue.shade700,
              onTap: () => _handleExport('share'),
            ),
          ],
        ),
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _isExporting ? null : onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withAlpha(128)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _handleExport(String type) async {
    if (_lastReport == null || _isExporting) return;

    setState(() => _isExporting = true);
    String? filePath;
    String message = '';

    try {
      if (type == 'pdf') {
        filePath = await PdfService.generateOperatingCostReport(summary: _lastReport!);
        message = 'PDF report generated successfully.';
      } else if (type == 'excel') {
        filePath = await ExcelService.exportOperatingCostReport(summary: _lastReport!);
        message = 'Excel report generated successfully.';
      } else if (type == 'share') {
        // Default to PDF for direct share
        filePath = await PdfService.generateOperatingCostReport(summary: _lastReport!);
      }

      if (filePath != null) {
        if (type == 'share') {
          await ShareService.shareFile(filePath);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            await ShareService.shareFile(filePath);
          }
        }
      } else {
        throw Exception('File generation failed.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildSmallInfo(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }
}
