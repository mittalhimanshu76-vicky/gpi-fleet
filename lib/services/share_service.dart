import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();



  /// Shares a file located at [filePath] using the native share sheet.
  ///
  /// Throws a [FileSystemException] if the file does not exist.
  /// Throws an [Exception] if the sharing process fails.
  static Future<void> shareFile(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('File does not exist at path: $filePath');
    }

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
        ),
      );

      if (result.status == ShareResultStatus.unavailable) {
        throw Exception('Sharing is unavailable on this device.');
      }
    } catch (e) {
      if (e is FileSystemException) rethrow;
      throw Exception('Failed to share file: $e');
    }
  }
}
