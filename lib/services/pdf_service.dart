import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'file:///C:/Users/user/AppData/Local/Pub/Cache/hosted/pub.dev/printing-5.15.0/lib/printing.dart';

class PdfService {
  PdfService._();

  static Future<String> generateExpenseReport({
    required List<Map<String, dynamic>> expenses,
    required String truckFilter,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + _parseAmount(expense['amount']),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'GPI Fleet',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Expense Report',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Filters Applied',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Truck: ${truckFilter == 'All Trucks' ? 'All Trucks' : truckFilter}',
            ),
            pw.Text(
              'Date From: ${fromDate == null ? '-' : dateFormat.format(fromDate)}',
            ),
            pw.Text(
              'Date To: ${toDate == null ? '-' : dateFormat.format(toDate)}',
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Table',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            expenses.isEmpty
                ? pw.Center(
                    child: pw.Text(
                      'No expense records found.',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  )
                : _buildExpenseTable(expenses, dateFormat),
            pw.SizedBox(height: 18),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Expenses: ₹ ${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generated on: ${dateTimeFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final directory = await getTemporaryDirectory();
    final file = File(
      p.join(
        directory.path,
        'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<void> openPdfPreview(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => file.readAsBytes(),
    );
  }

  static pw.Widget _buildExpenseTable(
    List<Map<String, dynamic>> expenses,
    DateFormat dateFormat,
  ) {
    final headers = [
      'Date',
      'Truck',
      'Driver',
      'Expense',
      'Paid By',
      'Payment Mode',
      'Amount',
    ];

    final data = expenses.map((expense) {
      return [
        _formatDate(expense['date']?.toString() ?? '', dateFormat),
        expense['truck_no']?.toString() ?? '',
        expense['driver_name']?.toString() ?? '',
        expense['expense_name']?.toString() ?? '',
        expense['paid_by']?.toString() ?? '',
        expense['payment_mode']?.toString() ?? '',
        '₹${_parseAmount(expense['amount']).toStringAsFixed(2)}',
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
      columnWidths: {
        0: const pw.FlexColumnWidth(1.3),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.3),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1.0),
        6: const pw.FlexColumnWidth(0.9),
      },
    );
  }

  static String _formatDate(String input, DateFormat formatter) {
    final parsed = DateTime.tryParse(input);
    if (parsed != null) return formatter.format(parsed);

    final parts = input.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return formatter.format(DateTime(year, month, day));
      }
    }

    return input;
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
