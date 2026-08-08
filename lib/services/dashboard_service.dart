import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();

  Future<DashboardSummary> getDashboardSummary() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final currentMonthStr = DateFormat('yyyy-MM').format(now);
    final previousMonthDate = DateTime(now.year, now.month - 1);
    final previousMonthStr = DateFormat('yyyy-MM').format(previousMonthDate);
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final sevenDaysLaterStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 7)));
    final thirtyDaysLaterStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 30)));

    // 1. Fleet Stats
    final fleetData = await db.rawQuery('''
      SELECT 
        (SELECT COUNT(*) FROM trucks) as total_trucks,
        (SELECT COUNT(*) FROM trucks WHERE status = 'Active') as active_trucks,
        (SELECT COUNT(*) FROM drivers WHERE status = 'Active') as active_drivers
    ''');
    final fleet = FleetStats(
      totalTrucks: fleetData.first['total_trucks'] as int,
      activeTrucks: fleetData.first['active_trucks'] as int,
      activeDrivers: fleetData.first['active_drivers'] as int,
    );

    // 2. Financials
    final currentMonthFinancials = await _getMonthlyFinancials(currentMonthStr);
    final previousMonthFinancials = await _getMonthlyFinancials(previousMonthStr);
    final financials = FinancialSummary(
      currentMonth: currentMonthFinancials,
      previousMonth: previousMonthFinancials,
    );

    // 3. Alerts
    final alertsData = await db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM maintenance_entries WHERE next_service_date BETWEEN ? AND ?) as due,
        (SELECT COUNT(*) FROM maintenance_entries WHERE next_service_date < ?) as overdue,
        (SELECT COUNT(*) FROM drivers WHERE license_expiry BETWEEN ? AND ?) as license
    ''', [todayStr, sevenDaysLaterStr, todayStr, todayStr, thirtyDaysLaterStr]);

    final alerts = AlertsSummary(
      maintenanceDue: alertsData.first['due'] as int,
      overdueMaintenance: alertsData.first['overdue'] as int,
      licenseExpiry: alertsData.first['license'] as int,
    );

    // 4. Top Maintenance Trucks
    final topMaintenanceData = await db.rawQuery('''
      SELECT t.truck_number, SUM(m.amount) as total_cost
      FROM maintenance_entries m
      JOIN trucks t ON m.truck_id = t.id
      WHERE m.date LIKE ?
      GROUP BY m.truck_id
      ORDER BY total_cost DESC
      LIMIT 3
    ''', ['$currentMonthStr%']);

    final topMaintenanceTrucks = topMaintenanceData.map((row) => TopTruckMaintenance(
      truckNumber: row['truck_number'] as String,
      cost: (row['total_cost'] as num).toDouble(),
    )).toList();

    // 5. Recent Activity
    final recentActivityData = await db.rawQuery('''
      SELECT * FROM (
        SELECT 'Expense' as type, t.truck_number, e.date, e.amount FROM expenses e JOIN trucks t ON e.truck_id = t.id
        UNION ALL
        SELECT 'Fuel' as type, t.truck_number, f.date, f.total_amount as amount FROM fuel_entries f JOIN trucks t ON f.truck_id = t.id
        UNION ALL
        SELECT 'Maintenance' as type, t.truck_number, m.date, m.amount FROM maintenance_entries m JOIN trucks t ON m.truck_id = t.id
      ) ORDER BY date DESC LIMIT 5
    ''');

    final recentActivities = recentActivityData.map((row) => RecentActivity(
      type: row['type'] as String,
      truckNumber: row['truck_number'] as String,
      date: row['date'] as String,
      amount: (row['amount'] as num).toDouble(),
    )).toList();

    return DashboardSummary(
      fleet: fleet,
      financials: financials,
      alerts: alerts,
      topMaintenanceTrucks: topMaintenanceTrucks,
      recentActivities: recentActivities,
    );
  }

  Future<MonthlyFinancials> _getMonthlyFinancials(String monthStr) async {
    final db = await DatabaseHelper.instance.database;
    final expenseRes = await db.rawQuery('SELECT SUM(amount) as total FROM expenses WHERE date LIKE ?', ['$monthStr%']);
    final fuelRes = await db.rawQuery('SELECT SUM(total_amount) as total FROM fuel_entries WHERE date LIKE ?', ['$monthStr%']);
    final maintRes = await db.rawQuery('SELECT SUM(amount) as total FROM maintenance_entries WHERE date LIKE ?', ['$monthStr%']);

    final e = (expenseRes.first['total'] as num?)?.toDouble() ?? 0.0;
    final f = (fuelRes.first['total'] as num?)?.toDouble() ?? 0.0;
    final m = (maintRes.first['total'] as num?)?.toDouble() ?? 0.0;

    return MonthlyFinancials(
      expenses: e,
      fuel: f,
      maintenance: m,
      total: e + f + m,
    );
  }
}
