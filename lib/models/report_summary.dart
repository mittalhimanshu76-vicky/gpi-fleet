class ReportSummary {
  final DateTime startDate;
  final DateTime endDate;
  final double expenseTotal;
  final double fuelTotal;
  final double maintenanceTotal;
  final double operatingCostTotal;
  final List<TruckCostSummary> truckCosts;

  ReportSummary({
    required this.startDate,
    required this.endDate,
    required this.expenseTotal,
    required this.fuelTotal,
    required this.maintenanceTotal,
    required this.operatingCostTotal,
    required this.truckCosts,
  });

  ReportSummary copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? expenseTotal,
    double? fuelTotal,
    double? maintenanceTotal,
    double? operatingCostTotal,
    List<TruckCostSummary>? truckCosts,
  }) {
    return ReportSummary(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expenseTotal: expenseTotal ?? this.expenseTotal,
      fuelTotal: fuelTotal ?? this.fuelTotal,
      maintenanceTotal: maintenanceTotal ?? this.maintenanceTotal,
      operatingCostTotal: operatingCostTotal ?? this.operatingCostTotal,
      truckCosts: truckCosts ?? this.truckCosts,
    );
  }
}

class TruckCostSummary {
  final int truckId;
  final String truckNumber;
  final double expenseTotal;
  final double fuelTotal;
  final double maintenanceTotal;
  final double operatingCostTotal;
  final int maintenanceCount;

  TruckCostSummary({
    required this.truckId,
    required this.truckNumber,
    required this.expenseTotal,
    required this.fuelTotal,
    required this.maintenanceTotal,
    required this.operatingCostTotal,
    required this.maintenanceCount,
  });

  TruckCostSummary copyWith({
    int? truckId,
    String? truckNumber,
    double? expenseTotal,
    double? fuelTotal,
    double? maintenanceTotal,
    double? operatingCostTotal,
    int? maintenanceCount,
  }) {
    return TruckCostSummary(
      truckId: truckId ?? this.truckId,
      truckNumber: truckNumber ?? this.truckNumber,
      expenseTotal: expenseTotal ?? this.expenseTotal,
      fuelTotal: fuelTotal ?? this.fuelTotal,
      maintenanceTotal: maintenanceTotal ?? this.maintenanceTotal,
      operatingCostTotal: operatingCostTotal ?? this.operatingCostTotal,
      maintenanceCount: maintenanceCount ?? this.maintenanceCount,
    );
  }
}
