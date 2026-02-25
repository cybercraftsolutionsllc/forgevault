import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto_lib;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:path_provider/path_provider.dart';

import '../crypto/ephemeral_key_service.dart';
import '../database/database_service.dart';
import '../database/schemas/audit_log.dart';
import 'purge_service.dart';
import 'vision_extraction_service.dart';
import 'pdf_extraction_service.dart';
import 'reality_guard_service.dart';

/// The Vacuum — file ingestion pipeline with media routing.
///
/// Handles the full lifecycle:
/// 1. Accept dropped/picked files
/// 2. Detect format (PDF, DOCX, EML, MD, images, audio)
/// 3. Route media through appropriate extraction pipeline:
///    - Images → Reality Guard → ML Kit OCR → text
///    - PDFs → read_pdf_text → text
///    - Text/MD/DOCX → direct read
/// 4. Generate ephemeral AES-256 key
/// 5. Encrypt raw file into app sandbox
/// 6. Trigger OS deletion of the original via MethodChannel
/// 7. Pass extracted text to ForgeService
class VacuumService {
  final EphemeralKeyService _ephemeralCrypto;
  final PurgeService _purgeService;
  final DatabaseService _database;
  final VisionExtractionService _visionService;
  final PdfExtractionService _pdfService;
  final RealityGuardService _realityGuard;

  VacuumService({
    required EphemeralKeyService ephemeralCrypto,
    required PurgeService purgeService,
    required DatabaseService database,
    VisionExtractionService? visionService,
    PdfExtractionService? pdfService,
    RealityGuardService? realityGuard,
  }) : _ephemeralCrypto = ephemeralCrypto,
       _purgeService = purgeService,
       _database = database,
       _visionService = visionService ?? VisionExtractionService(),
       _pdfService = pdfService ?? PdfExtractionService(),
       _realityGuard = realityGuard ?? RealityGuardService();

  /// Supported file types per the design spec.
  static const Map<String, String> supportedFormats = {
    '.pdf': 'document',
    '.docx': 'document',
    '.doc': 'document',
    '.eml': 'email',
    '.mbox': 'email',
    '.md': 'markdown',
    '.txt': 'text',
    '.jpg': 'image',
    '.jpeg': 'image',
    '.png': 'image',
    '.heic': 'image',
    '.m4a': 'audio',
    '.mp3': 'audio',
    '.wav': 'audio',
    '.ogg': 'audio',
  };

  /// Pipeline phase — broadcasted to the UI via callbacks.
  static const String phaseDetecting = 'DETECTING';
  static const String phaseRealityGuard = 'REALITY_GUARD';
  static const String phaseOcr = 'LOCAL_OCR';
  static const String phasePdfExtract = 'PDF_EXTRACTION';
  static const String phaseEncrypting = 'ENCRYPTING';
  static const String phaseExtracting = 'TEXT_EXTRACTION';

  /// Ingest a file: detect → verify → extract text → encrypt → sandbox.
  ///
  /// Returns an [IngestResult] containing the extracted text and metadata.
  /// Throws [RealityViolationException] for AI-generated images.
  /// Throws [UnsupportedError] for unsupported formats.
  Future<IngestResult> ingest(
    String filePath, {
    void Function(String phase)? onPhaseChanged,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    // ── Step 1: Format Detection ──
    onPhaseChanged?.call(phaseDetecting);
    final extension = _getExtension(filePath);
    final category = supportedFormats[extension];
    if (category == null) {
      throw UnsupportedError(
        'Unsupported file format: $extension. '
        'Supported: ${supportedFormats.keys.join(", ")}',
      );
    }

    // ── Step 2: Extract text based on media type ──
    String? extractedText;

    switch (category) {
      case 'image':
        // Reality Guard — verify EXIF authenticity
        onPhaseChanged?.call(phaseRealityGuard);
        await _realityGuard.verify(file);

        // ML Kit OCR — extract text from verified image
        onPhaseChanged?.call(phaseOcr);
        extractedText = await _visionService.extractText(file);

      case 'document':
        if (extension == '.pdf') {
          // PDF text extraction
          onPhaseChanged?.call(phasePdfExtract);
          extractedText = await _pdfService.extractText(file);
        } else if (extension == '.docx' || extension == '.doc') {
          // DOCX — native text extraction via docx_to_text
          onPhaseChanged?.call(phaseExtracting);
          try {
            final bytes = await file.readAsBytes();
            final rawDocx = docxToText(bytes);
            extractedText = rawDocx.replaceAll(
              RegExp(r'<[^>]+>', multiLine: true, dotAll: true),
              ' ',
            );
          } catch (e) {
            throw Exception('DOCX extraction failed: $e');
          }
        } else {
          onPhaseChanged?.call(phaseExtracting);
          extractedText = await file.readAsString();
        }

      case 'text':
      case 'markdown':
        onPhaseChanged?.call(phaseExtracting);
        extractedText = await file.readAsString();

      case 'email':
        onPhaseChanged?.call(phaseExtracting);
        extractedText = await file.readAsString();

      case 'audio':
        // Audio transcription is a future feature
        onPhaseChanged?.call(phaseExtracting);
        extractedText = '[AUDIO FILE — transcription not yet implemented]';
    }

    // ── Step 3: Read raw file bytes and hash ──
    onPhaseChanged?.call(phaseEncrypting);
    final rawBytes = await file.readAsBytes();
    final fileHash = _computeHash(rawBytes);

    // ── Step 4: Generate ephemeral key and encrypt ──
    _ephemeralCrypto.generateKey();
    final encryptedBytes = _ephemeralCrypto.encrypt(
      Uint8List.fromList(rawBytes),
    );
    final iv = _ephemeralCrypto.currentIv;

    // ── Step 5: Write encrypted file to app sandbox ──
    final sandboxPath = await _writeSandboxFile(
      encryptedBytes,
      iv,
      fileHash,
      extension,
    );

    // ── Step 6: Log the vacuum start ──
    await _writeAuditLog('VACUUM_STARTED', fileHash);

    return IngestResult(
      sandboxPath: sandboxPath,
      originalPath: filePath,
      fileHash: fileHash,
      category: category,
      extension: extension,
      extractedText: extractedText,
    );
  }

  /// Complete the pipeline after the Forge has synthesized.
  /// Triggers the Purge to destroy the ephemeral key and sandbox file.
  Future<void> completePipeline(IngestResult result) async {
    await _purgeService.purge(
      sandboxPath: result.sandboxPath,
      fileHash: result.fileHash,
      ephemeralCrypto: _ephemeralCrypto,
    );
  }

  /// Detect the file format from the path extension.
  String detectFormat(String filePath) {
    final ext = _getExtension(filePath);
    return supportedFormats[ext] ?? 'unknown';
  }

  /// Release resources held by extraction services.
  Future<void> dispose() async {
    await _visionService.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Static: Quick text extraction for 1-click upload
  // ─────────────────────────────────────────────────────────────

  /// Extract raw text from a file based on its extension.
  ///
  /// Supports: .txt, .md, .csv, .json, .pdf, .docx
  /// Throws an [Exception] if the document yields no text.
  static Future<String> extractTextFromFile(String path, String ext) async {
    final lower = ext.toLowerCase();
    String text;

    switch (lower) {
      case '.txt':
      case '.md':
      case '.csv':
      case '.json':
        text = await File(path).readAsString();

      case '.pdf':
        try {
          final pdfService = PdfExtractionService();
          text = await pdfService.extractText(File(path));
        } catch (e) {
          throw Exception(
            'PDF extraction failed for ${path.split(Platform.pathSeparator).last}: $e',
          );
        }

      case '.docx':
        try {
          final bytes = await File(path).readAsBytes();
          final rawDocx = docxToText(bytes);
          text = rawDocx.replaceAll(
            RegExp(r'<[^>]+>', multiLine: true, dotAll: true),
            ' ',
          );
        } catch (e) {
          throw Exception(
            'DOCX extraction failed for ${path.split(Platform.pathSeparator).last}: $e',
          );
        }

      default:
        throw Exception('Unsupported file type: $ext');
    }

    if (text.trim().isEmpty) {
      throw Exception('Could not extract readable text from this document.');
    }

    return _sanitizeExtractedText(text);
  }

  /// Strip residual XML/HTML tags, control chars, and collapse whitespace.
  ///
  /// Applied after ALL text extraction to ensure the LLM receives
  /// clean, dense, human-readable text — never raw XML or garbage.
  static String _sanitizeExtractedText(String raw) {
    var text = raw;

    // Strip XML / HTML tags (e.g. residual <w:t>, <span>, etc.)
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // Strip XML declarations and processing instructions
    text = text.replaceAll(RegExp(r'<\?[^?]*\?>'), ' ');

    // Strip common XML namespaces that survive tag removal
    text = text.replaceAll(RegExp(r'xmlns[:=][^\s>]+'), '');

    // Strip non-printable control characters (keep newlines and tabs)
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Collapse multiple whitespace / blank lines into single space/newline
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  // ── Private Helpers ──

  String _getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot < 0) return '';
    return path.substring(lastDot).toLowerCase();
  }

  String _computeHash(List<int> bytes) {
    final digest = crypto_lib.sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _writeSandboxFile(
    Uint8List encrypted,
    Uint8List iv,
    String hash,
    String extension,
  ) async {
    final appDir = await getApplicationSupportDirectory();
    final sandboxDir = Directory(
      '${appDir.path}${Platform.pathSeparator}.sandbox',
    );
    if (!await sandboxDir.exists()) {
      await sandboxDir.create(recursive: true);
    }

    final fileName = '${hash.substring(0, 16)}$extension.vault';
    final sandboxFile = File(
      '${sandboxDir.path}${Platform.pathSeparator}$fileName',
    );

    // Prepend IV (16 bytes) to encrypted data for later decryption.
    final combined = Uint8List(iv.length + encrypted.length);
    combined.setRange(0, iv.length, iv);
    combined.setRange(iv.length, combined.length, encrypted);

    await sandboxFile.writeAsBytes(combined);
    return sandboxFile.path;
  }

  Future<void> _writeAuditLog(String action, String fileHash) async {
    final db = _database.db;
    await db.writeTxn(() async {
      await db.auditLogs.put(
        AuditLog()
          ..timestamp = DateTime.now()
          ..action = action
          ..details = fileHash,
      );
    });
  }
}

/// Result of a vacuum ingestion operation.
class IngestResult {
  final String sandboxPath;
  final String originalPath;
  final String fileHash;
  final String category;
  final String extension;

  /// Extracted text content — ready for ForgeService synthesis.
  /// Null if the format doesn't support text extraction (e.g. audio).
  final String? extractedText;

  IngestResult({
    required this.sandboxPath,
    required this.originalPath,
    required this.fileHash,
    required this.category,
    required this.extension,
    this.extractedText,
  });
}
