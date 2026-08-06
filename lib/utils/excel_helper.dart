import 'package:excel/excel.dart';

class ExcelHelper {
  static Future<List<int>> generateHistoryExcel(
    List<Map<String, dynamic>> expenses,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Expenses'];

    final headers = [
      'Date',
      'Truck',
      'Driver',
      'Expense',
      'Amount',
      'Paid By',
      'Mode',
      'Remarks',
    ];

    sheet.appendRow(headers);

    for (final expense in expenses) {
      sheet.appendRow([
        expense['date']?.toString() ?? '',
        expense['truck_no']?.toString() ?? '',
        expense['driver_name']?.toString() ?? '',
        expense['expense_name']?.toString() ?? '',
        expense['amount']?.toString() ?? '',
        expense['paid_by']?.toString() ?? '',
        expense['payment_mode']?.toString() ?? '',
        expense['remarks']?.toString() ?? '',
      ]);
    }

    final encoded = excel.save();
    if (encoded == null) return <int>[];
    return encoded;
  }
}
