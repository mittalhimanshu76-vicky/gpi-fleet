class Truck {
  final int? id;
  final String truckNo;

  Truck({
    this.id,
    required this.truckNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'truck_no': truckNo,
    };
  }

  factory Truck.fromMap(Map<String, dynamic> map) {
    return Truck(
      id: map['id'],
      truckNo: map['truck_no'],
    );
  }
}