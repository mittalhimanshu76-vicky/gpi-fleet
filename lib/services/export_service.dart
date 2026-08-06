import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/excel_helper.dart';
import '../utils/pdf_helper.dart';

enum ExportFormat { pdf, excel }

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  Future<String> exportHistory(
    List<Map<String, dynamic>> expenses,
    ExportFormat format,
  ) async {
    final bytes = await _generateBytes(expenses, format);
    final directory = await getTemporaryDirectory();
    final fileName = _buildFileName(format);
    final file = File(join(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<List<int>> _generateBytes(
    List<Map<String, dynamic>> expenses,
    ExportFormat format,
  ) {
    switch (format) {
      case ExportFormat.pdf:
        return PdfHelper.generateHistoryPdf(expenses);
      case ExportFormat.excel:
        return ExcelHelper.generateHistoryExcel(expenses);
    }
  }

  String _buildFileName(ExportFormat format) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    switch (format) {
      case ExportFormat.pdf:
        return 'expense_history_$timestamp.pdf';
      case ExportFormat.excel:
        return 'expense_history_$timestamp.xlsx';
    }
  }
}
