import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHelper {
  static Future<List<int>> generateHistoryPdf(
    List<Map<String, dynamic>> expenses,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(level: 0, child: pw.Text('Expense History')),
            pw.SizedBox(height: 8),
            _buildTable(expenses),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> expenses) {
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

    final data = expenses.map((expense) {
      return [
        expense['date']?.toString() ?? '',
        expense['truck_no']?.toString() ?? '',
        expense['driver_name']?.toString() ?? '',
        expense['expense_name']?.toString() ?? '',
        expense['amount']?.toString() ?? '',
        expense['paid_by']?.toString() ?? '',
        expense['payment_mode']?.toString() ?? '',
        expense['remarks']?.toString() ?? '',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }
}
