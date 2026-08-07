class Driver {
  final int? id;
  final String driverName;
  final String? mobileNumber;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? joiningDate;
  final String? address;
  final String? emergencyContact;
  final String? aadhaarNumber;
  final String status;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  Driver({
    this.id,
    required this.driverName,
    this.mobileNumber,
    this.licenseNumber,
    this.licenseExpiry,
    this.joiningDate,
    this.address,
    this.emergencyContact,
    this.aadhaarNumber,
    this.status = 'Active',
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driver_name': driverName,
      'mobile_number': mobileNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'joining_date': joiningDate,
      'address': address,
      'emergency_contact': emergencyContact,
      'aadhaar_number': aadhaarNumber,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as int?,
      driverName: map['driver_name'] as String? ?? map['name'] as String? ?? '',
      mobileNumber: map['mobile_number'] as String?,
      licenseNumber: map['license_number'] as String?,
      licenseExpiry: map['license_expiry'] as String?,
      joiningDate: map['joining_date'] as String?,
      address: map['address'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
      aadhaarNumber: map['aadhaar_number'] as String?,
      status: map['status'] as String? ?? 'Active',
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Driver copyWith({
    int? id,
    String? driverName,
    String? mobileNumber,
    String? licenseNumber,
    String? licenseExpiry,
    String? joiningDate,
    String? address,
    String? emergencyContact,
    String? aadhaarNumber,
    String? status,
    String? remarks,
    String? createdAt,
    String? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      driverName: driverName ?? this.driverName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      joiningDate: joiningDate ?? this.joiningDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
