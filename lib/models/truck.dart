class Truck {
  final int? id;
  final String truckNumber;
  final String? vehicleType;
  final String? make;
  final String? model;
  final String? ownerName;
  final String? registrationNumber;
  final String status;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  Truck({
    this.id,
    required this.truckNumber,
    this.vehicleType,
    this.make,
    this.model,
    this.ownerName,
    this.registrationNumber,
    this.status = 'Active',
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'truck_number': truckNumber,
      'vehicle_type': vehicleType,
      'make': make,
      'model': model,
      'owner_name': ownerName,
      'registration_number': registrationNumber,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Truck.fromMap(Map<String, dynamic> map) {
    return Truck(
      id: map['id'] as int?,
      truckNumber: map['truck_number'] as String,
      vehicleType: map['vehicle_type'] as String?,
      make: map['make'] as String?,
      model: map['model'] as String?,
      ownerName: map['owner_name'] as String?,
      registrationNumber: map['registration_number'] as String?,
      status: map['status'] as String? ?? 'Active',
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Truck copyWith({
    int? id,
    String? truckNumber,
    String? vehicleType,
    String? make,
    String? model,
    String? ownerName,
    String? registrationNumber,
    String? status,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return Truck(
      id: id ?? this.id,
      truckNumber: truckNumber ?? this.truckNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      make: make ?? this.make,
      model: model ?? this.model,
      ownerName: ownerName ?? this.ownerName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
