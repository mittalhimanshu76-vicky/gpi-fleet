import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/report_summary.dart';

class ReportsService {
  ReportsService._();

  static final ReportsService instance = ReportsService._();

  /// Generates a comprehensive operating cost report for the entire fleet
  /// within the specified date range.
  Future<ReportSummary> getFleetOperatingReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final df = DateFormat('yyyy-MM-dd');
    final startStr = df.format(startDate);
    final endStr = df.format(endDate);

    final data = await DatabaseHelper.instance.queryTruckOperatingCosts(startStr, endStr);

    double totalExp = 0;
    double totalFuel = 0;
    double totalMaint = 0;

    final truckCosts = data.map((row) {
      final exp = (row['expense_total'] as num).toDouble();
      final fuel = (row['fuel_total'] as num).toDouble();
      final maint = (row['maintenance_total'] as num).toDouble();
      final operating = exp + fuel + maint;

      totalExp += exp;
      totalFuel += fuel;
      totalMaint += maint;

      return TruckCostSummary(
        truckId: row['id'] as int,
        truckNumber: row['truck_number'] as String,
        expenseTotal: exp,
        fuelTotal: fuel,
        maintenanceTotal: maint,
        operatingCostTotal: operating,
      );
    }).toList();

    return ReportSummary(
      startDate: startDate,
      endDate: endDate,
      expenseTotal: totalExp,
      fuelTotal: totalFuel,
      maintenanceTotal: totalMaint,
      operatingCostTotal: totalExp + totalFuel + totalMaint,
      truckCosts: truckCosts,
    );
  }
}
