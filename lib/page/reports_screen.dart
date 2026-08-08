import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_summary.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  late Future<ReportSummary> _reportFuture;

  @override
  void initState() {
    super.initState();
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
                if (report.truckCosts.isEmpty) {
                  return const Center(child: Text('No transactions found for this period.'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadReport(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(report),
                        const SizedBox(height: 24),
                        const Text(
                          'Truck-wise Breakdown',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...report.truckCosts.map((tc) => _buildTruckCostCard(tc)),
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

  Widget _buildSummaryCards(ReportSummary report) {
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
            _buildStatCard('Maintenance', report.maintenanceTotal, Colors.brown),
            const SizedBox(width: 12),
            _buildStatCard('Total Cost', report.operatingCostTotal, Colors.green, isPrimary: true),
          ],
        ),
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

  Widget _buildSmallInfo(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }
}
