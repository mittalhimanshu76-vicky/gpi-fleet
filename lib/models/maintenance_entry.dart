class MaintenanceEntry {
  final int? id;
  final int truckId;
  final String? truckNumber; // Joined from trucks table
  final String date;
  final String maintenanceType;
  final String? description;
  final double? odometer;
  final double amount;
  final String? serviceProvider;
  final String? nextServiceDate;
  final double? nextServiceOdometer;
  final String? paymentMode;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  MaintenanceEntry({
    this.id,
    required this.truckId,
    this.truckNumber,
    required this.date,
    required this.maintenanceType,
    this.description,
    this.odometer,
    required this.amount,
    this.serviceProvider,
    this.nextServiceDate,
    this.nextServiceOdometer,
    this.paymentMode,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'truck_id': truckId,
      'date': date,
      'maintenance_type': maintenanceType,
      'description': description,
      'odometer': odometer,
      'amount': amount,
      'service_provider': serviceProvider,
      'next_service_date': nextServiceDate,
      'next_service_odometer': nextServiceOdometer,
      'payment_mode': paymentMode,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['id'] as int?,
      truckId: map['truck_id'] as int,
      truckNumber: map['truck_number'] as String?,
      date: map['date'] as String,
      maintenanceType: map['maintenance_type'] as String,
      description: map['description'] as String?,
      odometer: map['odometer'] as double?,
      amount: (map['amount'] as num).toDouble(),
      serviceProvider: map['service_provider'] as String?,
      nextServiceDate: map['next_service_date'] as String?,
      nextServiceOdometer: map['next_service_odometer'] as double?,
      paymentMode: map['payment_mode'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  MaintenanceEntry copyWith({
    int? id,
    int? truckId,
    String? truckNumber,
    String? date,
    String? maintenanceType,
    String? description,
    double? odometer,
    double? amount,
    String? serviceProvider,
    String? nextServiceDate,
    double? nextServiceOdometer,
    String? paymentMode,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return MaintenanceEntry(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      truckNumber: truckNumber ?? this.truckNumber,
      date: date ?? this.date,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      description: description ?? this.description,
      odometer: odometer ?? this.odometer,
      amount: amount ?? this.amount,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      paymentMode: paymentMode ?? this.paymentMode,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
