class DashboardSummary {
  final FleetStats fleet;
  final FinancialSummary financials;
  final AlertsSummary alerts;
  final List<TopTruckMaintenance> topMaintenanceTrucks;
  final List<RecentActivity> recentActivities;

  DashboardSummary({
    required this.fleet,
    required this.financials,
    required this.alerts,
    required this.topMaintenanceTrucks,
    required this.recentActivities,
  });
}

class FleetStats {
  final int totalTrucks;
  final int activeTrucks;
  final int activeDrivers;

  FleetStats({
    required this.totalTrucks,
    required this.activeTrucks,
    required this.activeDrivers,
  });
}

class FinancialSummary {
  final MonthlyFinancials currentMonth;
  final MonthlyFinancials previousMonth;

  FinancialSummary({
    required this.currentMonth,
    required this.previousMonth,
  });

  double get trendPercentage {
    if (previousMonth.total == 0) return 0;
    return ((currentMonth.total - previousMonth.total) / previousMonth.total) * 100;
  }
}

class MonthlyFinancials {
  final double expenses;
  final double fuel;
  final double maintenance;
  final double total;

  MonthlyFinancials({
    required this.expenses,
    required this.fuel,
    required this.maintenance,
    required this.total,
  });
}

class AlertsSummary {
  final int maintenanceDue;
  final int overdueMaintenance;
  final int licenseExpiry;

  AlertsSummary({
    required this.maintenanceDue,
    required this.overdueMaintenance,
    required this.licenseExpiry,
  });
}

class TopTruckMaintenance {
  final String truckNumber;
  final double cost;

  TopTruckMaintenance({
    required this.truckNumber,
    required this.cost,
  });
}

class RecentActivity {
  final String type;
  final String truckNumber;
  final String date;
  final double amount;

  RecentActivity({
    required this.type,
    required this.truckNumber,
    required this.date,
    required this.amount,
  });
}
