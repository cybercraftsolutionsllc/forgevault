import 'dart:io';

import 'package:read_pdf_text/read_pdf_text.dart';

/// Local PDF text extraction — no cloud calls.
///
/// Uses the `read_pdf_text` package which leverages platform-native
/// PDF readers (PDFKit on iOS, PdfRenderer on Android) to extract
/// raw text from each page.
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
      final List<String> pages = await ReadPdfText.getPDFtextPaginated(
        pdfFile.path,
      );

      if (pages.isEmpty) {
        throw PdfExtractionException(
          'No text extracted from PDF: ${pdfFile.path}',
        );
      }

      final buffer = StringBuffer();
      for (var i = 0; i < pages.length; i++) {
        final pageText = pages[i].trim();
        if (pageText.isNotEmpty) {
          buffer.writeln('--- Page ${i + 1} ---');
          buffer.writeln(pageText);
          buffer.writeln();
        }
      }

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
