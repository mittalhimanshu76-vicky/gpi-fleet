import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_summary.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'masters_screen.dart';
import 'truck_master_screen.dart';
import 'driver_master_screen.dart';
import 'fuel_screen.dart';
import 'maintenance_screen.dart';
import 'more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DashboardSummary> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _dashboardFuture = DashboardService.instance.getDashboardSummary();
    });
  }

  Future<void> openScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPI Fleet', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<DashboardSummary>(
        future: _dashboardFuture,
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
                  Text('Failed to load dashboard: ${snapshot.error}'),
                  TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset('assets/image/gpi_logo.png', height: 80)),
                  const SizedBox(height: 24),

                  _buildFleetOverview(data.fleet),
                  const SizedBox(height: 24),

                  _buildFinancialSection(data.financials),
                  const SizedBox(height: 24),

                  _buildFleetHealth(data.alerts),
                  const SizedBox(height: 24),

                  _buildPerformanceSection(data),
                  const SizedBox(height: 24),

                  _buildRecentActivity(data.recentActivities),
                  const SizedBox(height: 24),

                  _buildNavigationSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFleetOverview(FleetStats stats) {
    return Row(
      children: [
        _buildStatChip('Trucks', stats.totalTrucks.toString(), Colors.blue),
        const SizedBox(width: 8),
        _buildStatChip('Active', stats.activeTrucks.toString(), Colors.green),
        const SizedBox(width: 8),
        _buildStatChip('Drivers', stats.activeDrivers.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(50)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12, color: color.withAlpha(200))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSection(FinancialSummary summary) {
    final trend = summary.trendPercentage;
    final isUp = trend > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Operating Cost (Month)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isUp ? Colors.red : Colors.green).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: isUp ? Colors.red : Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.abs().toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUp ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${summary.currentMonth.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMinorFinancial('Expenses', summary.currentMonth.expenses, Colors.blue),
                _buildMinorFinancial('Fuel', summary.currentMonth.fuel, Colors.orange),
                _buildMinorFinancial('Maint.', summary.currentMonth.maintenance, Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinorFinancial(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildFleetHealth(AlertsSummary alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fleet Health & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAlertBox('Overdue', alerts.overdueMaintenance, Colors.red),
            const SizedBox(width: 8),
            _buildAlertBox('Due Soon', alerts.maintenanceDue, Colors.orange),
            const SizedBox(width: 8),
            _buildAlertBox('License Exp.', alerts.licenseExpiry, Colors.blueGrey),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertBox(String label, int count, Color color) {
    final isZero = count == 0;
    final displayColor = isZero ? Colors.green : color;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: displayColor.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: displayColor.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: displayColor),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: displayColor.withAlpha(200)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(DashboardSummary data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildTopMaintenance(data.topMaintenanceTrucks),
      ],
    );
  }

  Widget _buildTopMaintenance(List<TopTruckMaintenance> trucks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Maintenance (Month)', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (trucks.isEmpty)
            const Text('No data recorded', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            ...trucks.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.truckNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('₹${t.cost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.brown)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          const Text('No recent activity', style: TextStyle(color: Colors.grey))
        else
          ...activities.map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(a.type).withAlpha(30),
                  child: Icon(_getActivityIcon(a.type), size: 20, color: _getActivityColor(a.type)),
                ),
                title: Text('${a.type}: ${a.truckNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(a.date, style: const TextStyle(fontSize: 12)),
                trailing: Text('₹${a.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
      ],
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Expense': return Colors.blue;
      case 'Fuel': return Colors.orange;
      case 'Maintenance': return Colors.brown;
      default: return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Expense': return Icons.receipt_long;
      case 'Fuel': return Icons.local_gas_station;
      case 'Maintenance': return Icons.build;
      default: return Icons.info_outline;
    }
  }

  Widget _buildNavigationSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildNavButton(Icons.add_circle, 'New Expense', Colors.blue, () => openScreen(const AddExpenseScreen())),
        _buildNavButton(Icons.history, 'History', Colors.green, () => openScreen(const ExpenseHistoryScreen())),
        _buildNavButton(Icons.local_gas_station, 'Fuel', Colors.orange, () => openScreen(const FuelScreen())),
        _buildNavButton(Icons.build, 'Maintenance', Colors.brown, () => openScreen(const MaintenanceScreen())),
        _buildNavButton(Icons.person, 'Drivers', Colors.teal, () => openScreen(const DriverMasterScreen())),
        _buildNavButton(Icons.local_shipping, 'Trucks', Colors.indigo, () => openScreen(const TruckMasterScreen())),
        _buildNavButton(Icons.settings, 'Masters', Colors.purple, () => openScreen(const MastersScreen())),
        _buildNavButton(Icons.more_horiz, 'More', Colors.blueGrey, () => openScreen(const MoreScreen())),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, String label, Color color, VoidCallback onTap) {
    final width = (MediaQuery.of(context).size.width - 32 - 12) / 2;
    return SizedBox(
      width: width,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
