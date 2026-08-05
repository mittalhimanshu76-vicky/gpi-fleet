class Expense {
  final int? id;
  final String date;
  final int driverId;
  final int truckId;
  final double amount;
  final String paidBy;
  final String paymentMode;
  final String expenseName;
  final String remarks;

  Expense({
    this.id,
    required this.date,
    required this.driverId,
    required this.truckId,
    required this.amount,
    required this.paidBy,
    required this.paymentMode,
    required this.expenseName,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'driver_id': driverId,
      'truck_id': truckId,
      'amount': amount,
      'paid_by': paidBy,
      'payment_mode': paymentMode,
      'expense_name': expenseName,
      'remarks': remarks,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: map['date'],
      driverId: map['driver_id'],
      truckId: map['truck_id'],
      amount: map['amount'],
      paidBy: map['paid_by'],
      paymentMode: map['payment_mode'],
      expenseName: map['expense_name'],
      remarks: map['remarks'],
    );
  }
}