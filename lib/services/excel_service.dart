import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExcelService {
  ExcelService._();

  static Future<String?> exportExpenseReport({
    required List<Map<String, dynamic>> expenses,
    required String truckFilter,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Expense Report'];
      final dateFormat = DateFormat('yyyy-MM-dd');
      final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
      final generatedOn = dateTimeFormat.format(DateTime.now());
      final headers = [
        'Date',
        'Truck Number',
        'Driver',
        'Expense',
        'Paid By',
        'Payment Mode',
        'Amount',
      ];
      final companyName = 'GAUTAM PARKASH INDIA PRIVATE LIMITED';
      final title = 'EXPENSE REPORT';
      final totalAmount = expenses.fold<double>(
        0,
        (sum, expense) => sum + _parseAmount(expense['amount']),
      );

      final companyStyle = _baseStyle(
        bold: true,
        fontSize: 13,
        colorHex: 'FF2E7D32',
        horizontalAlignment: HorizontalAlign.Center,
      );
      final titleStyle = _baseStyle(
        bold: true,
        fontSize: 16,
        colorHex: 'FF2E7D32',
        horizontalAlignment: HorizontalAlign.Center,
      );
      final detailStyle = _baseStyle(
        fontSize: 10,
        horizontalAlignment: HorizontalAlign.Left,
      );
      final headerStyle = _baseStyle(
        bold: true,
        fontSize: 11,
        colorHex: 'FFFFFFFF',
        backgroundColorHex: 'FF2E7D32',
        horizontalAlignment: HorizontalAlign.Center,
      );
      final bodyStyle = _baseStyle(
        fontSize: 10,
        horizontalAlignment: HorizontalAlign.Left,
      );
      final amountStyle = _baseStyle(
        fontSize: 10,
        horizontalAlignment: HorizontalAlign.Right,
      );
      final grandTotalStyle = _baseStyle(
        bold: true,
        fontSize: 11,
        colorHex: 'FFFFFFFF',
        backgroundColorHex: 'FF2E7D32',
        horizontalAlignment: HorizontalAlign.Left,
      );

      _setCell(sheet, 0, 0, companyName, style: companyStyle);
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: 0,
        ),
      );

      _setCell(sheet, 1, 0, title, style: titleStyle);
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: 1,
        ),
      );

      _setCell(
        sheet,
        3,
        0,
        'Truck: ${truckFilter == 'All Trucks' ? 'All Trucks' : truckFilter}',
        style: detailStyle,
      );
      _setCell(
        sheet,
        4,
        0,
        'From Date: ${fromDate == null ? '-' : dateFormat.format(fromDate)}',
        style: detailStyle,
      );
      _setCell(
        sheet,
        5,
        0,
        'To Date: ${toDate == null ? '-' : dateFormat.format(toDate)}',
        style: detailStyle,
      );
      _setCell(sheet, 6, 0, 'Generated On: $generatedOn', style: detailStyle);

      final headerRow = 8;
      for (var index = 0; index < headers.length; index++) {
        _setCell(sheet, headerRow, index, headers[index], style: headerStyle);
      }

      for (var index = 0; index < expenses.length; index++) {
        final expense = expenses[index];
        final rowIndex = headerRow + 1 + index;
        final amount = _formatCurrency(_parseAmount(expense['amount']));
        final rowStyle = index.isEven
            ? bodyStyle
            : bodyStyle.copyWith(backgroundColorHexVal: 'FFF5F5F5');

        _setCell(
          sheet,
          rowIndex,
          0,
          _formatDate(expense['date']?.toString() ?? '', dateFormat),
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          1,
          expense['truck_no']?.toString() ?? '',
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          2,
          expense['driver_name']?.toString() ?? '',
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          3,
          expense['expense_name']?.toString() ?? '',
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          4,
          expense['paid_by']?.toString() ?? '',
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          5,
          expense['payment_mode']?.toString() ?? '',
          style: rowStyle,
        );
        _setCell(
          sheet,
          rowIndex,
          6,
          amount,
          style: amountStyle.copyWith(
            backgroundColorHexVal: index.isEven ? 'FFFFFFFF' : 'FFF5F5F5',
          ),
        );
      }

      final totalRowIndex = headerRow + 1 + expenses.length;
      _setCell(sheet, totalRowIndex, 0, 'GRAND TOTAL', style: grandTotalStyle);
      _setCell(
        sheet,
        totalRowIndex,
        6,
        _formatCurrency(totalAmount),
        style: grandTotalStyle.copyWith(
          horizontalAlignVal: HorizontalAlign.Right,
        ),
      );
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: totalRowIndex),
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRowIndex),
      );

      _applyBorders(sheet, 0, totalRowIndex, 0, headers.length - 1);

      final downloadsDir = await getDownloadsDirectory();
      final documentsDir = await getApplicationDocumentsDirectory();
      final targetDir = downloadsDir ?? documentsDir;
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = path.join(
        targetDir.path,
        'expense_report_$timestamp.xlsx',
      );
      final file = File(filePath);
      final bytes = excel.save();
      if (bytes == null) {
        return null;
      }
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, stackTrace) {
      debugPrint("Excel Export Error: $e");
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  static void _setCell(
    Sheet sheet,
    int row,
    int col,
    dynamic value, {
    CellStyle? style,
  }) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      value,
      cellStyle: style,
    );
  }

  static CellStyle _baseStyle({
    bool bold = false,
    int fontSize = 10,
    String colorHex = 'FF000000',
    String backgroundColorHex = 'FFFFFFFF',
    HorizontalAlign horizontalAlignment = HorizontalAlign.Left,
  }) {
    return CellStyle(
      bold: bold,
      fontSize: fontSize,
      fontColorHex: colorHex,
      backgroundColorHex: backgroundColorHex,
      horizontalAlign: horizontalAlignment,
      verticalAlign: VerticalAlign.Center,
      leftBorder: _thinBorder(),
      rightBorder: _thinBorder(),
      topBorder: _thinBorder(),
      bottomBorder: _thinBorder(),
    );
  }

  static Border _thinBorder() {
    return Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FFD0D0D0');
  }

  static void _applyBorders(
    Sheet sheet,
    int startRow,
    int endRow,
    int startCol,
    int endCol,
  ) {
    for (var row = startRow; row <= endRow; row++) {
      for (var col = startCol; col <= endCol; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
        );
        final baseStyle = cell.cellStyle ?? _baseStyle();
        cell.cellStyle = baseStyle.copyWith(
          leftBorderVal: _thinBorder(),
          rightBorderVal: _thinBorder(),
          topBorderVal: _thinBorder(),
          bottomBorderVal: _thinBorder(),
        );
      }
    }
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

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '₹ ${formatter.format(amount)}';
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
