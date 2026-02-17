import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR via Google ML Kit Text Recognition.
///
/// Processes image files (.jpg, .png, .heic) locally — no cloud calls.
/// Extracts all recognized text blocks and returns concatenated plain text
/// ready for the ForgeService synthesis pipeline.
class VisionExtractionService {
  TextRecognizer? _recognizer;

  /// Extract readable text from an image file using ML Kit.
  ///
  /// Returns the full concatenated text from all detected blocks.
  /// Throws [VisionExtractionException] if extraction fails.
  Future<String> extractText(File imageFile) async {
    if (!await imageFile.exists()) {
      throw VisionExtractionException(
        'Image file not found: ${imageFile.path}',
      );
    }

    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _recognizer!.processImage(
      inputImage,
    );

    if (recognizedText.text.isEmpty) {
      throw VisionExtractionException(
        'No text detected in image: ${imageFile.path}',
      );
    }

    // Build structured output preserving block/line structure
    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
      buffer.writeln(); // Blank line between blocks
    }

    return buffer.toString().trim();
  }

  /// Extract text with confidence filtering.
  ///
  /// Only includes text elements above the given confidence threshold (0.0-1.0).
  Future<String> extractTextWithConfidence(
    File imageFile, {
    double minConfidence = 0.5,
  }) async {
    if (!await imageFile.exists()) {
      throw VisionExtractionException(
        'Image file not found: ${imageFile.path}',
      );
    }

    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final RecognizedText recognizedText = await _recognizer!.processImage(
      inputImage,
    );

    final buffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          if (element.confidence != null &&
              element.confidence! >= minConfidence) {
            buffer.write('${element.text} ');
          }
        }
        buffer.writeln();
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  /// Release the ML Kit recognizer resources.
  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}

class VisionExtractionException implements Exception {
  final String message;
  VisionExtractionException(this.message);

  @override
  String toString() => 'VisionExtractionException: $message';
}
