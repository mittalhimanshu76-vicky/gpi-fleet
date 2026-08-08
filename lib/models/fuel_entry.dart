class FuelEntry {
  final int? id;
  final int truckId;
  final String? truckNumber; // Joined from trucks table
  final String date;
  final double? odometer;
  final double liters;
  final double? ratePerLiter;
  final double totalAmount;
  final String? fuelStation;
  final String? paymentMode;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  FuelEntry({
    this.id,
    required this.truckId,
    this.truckNumber,
    required this.date,
    this.odometer,
    required this.liters,
    this.ratePerLiter,
    required this.totalAmount,
    this.fuelStation,
    this.paymentMode,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'truck_id': truckId,
      'date': date,
      'odometer': odometer,
      'liters': liters,
      'rate_per_liter': ratePerLiter,
      'total_amount': totalAmount,
      'fuel_station': fuelStation,
      'payment_mode': paymentMode,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as int?,
      truckId: map['truck_id'] as int,
      truckNumber: map['truck_number'] as String?,
      date: map['date'] as String,
      odometer: map['odometer'] as double?,
      liters: map['liters'] as double,
      ratePerLiter: map['rate_per_liter'] as double?,
      totalAmount: map['total_amount'] as double,
      fuelStation: map['fuel_station'] as String?,
      paymentMode: map['payment_mode'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  FuelEntry copyWith({
    int? id,
    int? truckId,
    String? truckNumber,
    String? date,
    double? odometer,
    double? liters,
    double? ratePerLiter,
    double? totalAmount,
    String? fuelStation,
    String? paymentMode,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      truckNumber: truckNumber ?? this.truckNumber,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      ratePerLiter: ratePerLiter ?? this.ratePerLiter,
      totalAmount: totalAmount ?? this.totalAmount,
      fuelStation: fuelStation ?? this.fuelStation,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
