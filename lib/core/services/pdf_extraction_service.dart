import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Local PDF text extraction — no cloud calls, pure Dart.
///
/// Uses `syncfusion_flutter_pdf` which works on all platforms
/// (Windows, macOS, Linux, Android, iOS) without native channels.
class PdfExtractionService {
  /// Extract all text from a PDF file.
  ///
  /// Returns the concatenated text from all pages with page separators.
  /// Throws [PdfExtractionException] if extraction fails.
  Future<String> extractText(File pdfFile) async {
    if (!await pdfFile.exists()) {
      throw PdfExtractionException('PDF file not found: ${pdfFile.path}');
    }

    try {
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      final buffer = StringBuffer();
      for (var i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i).trim();
        if (pageText.isNotEmpty) {
          buffer.writeln('--- Page ${i + 1} ---');
          buffer.writeln(pageText);
          buffer.writeln();
        }
      }

      document.dispose();

      final result = buffer.toString().trim();
      if (result.isEmpty) {
        throw PdfExtractionException(
          'PDF contains no extractable text (may be image-only): ${pdfFile.path}',
        );
      }

      return result;
    } catch (e) {
      if (e is PdfExtractionException) rethrow;
      throw PdfExtractionException('Failed to extract text from PDF: $e');
    }
  }

  /// Check if a PDF file likely contains extractable text.
  ///
  /// Attempts extraction and returns true if any text is found.
  Future<bool> hasExtractableText(File pdfFile) async {
    try {
      final text = await extractText(pdfFile);
      return text.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

class PdfExtractionException implements Exception {
  final String message;
  PdfExtractionException(this.message);

  @override
  String toString() => 'PdfExtractionException: $message';
}
