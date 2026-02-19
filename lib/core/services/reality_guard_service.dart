import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';

/// Reality Guard — enforces the 'No AI-generated fakes' rule.
///
/// When an image is vacuumed, verifies it contains legitimate hardware
/// EXIF data (Camera Make, Model, DateTimeOriginal). Images that are
/// stripped of EXIF entirely or contain known AI-generation software
/// tags are rejected with a [RealityViolationException].
///
/// This guards against synthetic/deepfake content entering the vault
/// and corrupting the user's verified life record.
class RealityGuardService {
  /// Known AI generation software identifiers.
  static const List<String> _aiSoftwareTags = [
    'midjourney',
    'dall-e',
    'dall·e',
    'stable diffusion',
    'comfyui',
    'automatic1111',
    'invoke ai',
    'novelai',
    'adobe firefly',
    'photoshop generative fill',
    'photoshop ai',
    'playground ai',
    'leonardo ai',
    'ideogram',
    'flux',
  ];

  /// Minimum required EXIF fields for a "real" photograph.
  /// An image must have at least one of these to pass.
  static const List<String> _hardwareExifFields = [
    'Image Make',
    'Image Model',
    'EXIF DateTimeOriginal',
    'EXIF DateTimeDigitized',
    'EXIF FocalLength',
    'EXIF ISOSpeedRatings',
    'EXIF ExposureTime',
    'EXIF FNumber',
    'GPS GPSLatitude',
  ];

  /// Verify an image file for hardware EXIF authenticity.
  ///
  /// Throws [RealityViolationException] if:
  /// - EXIF data is completely stripped/missing
  /// - Known AI-generation software tags are detected
  ///
  /// Returns [ExifVerificationResult] on success.
  Future<ExifVerificationResult> verify(File imageFile) async {
    if (!await imageFile.exists()) {
      throw RealityViolationException(
        'Image file not found: ${imageFile.path}',
      );
    }

    final Uint8List bytes = await imageFile.readAsBytes();
    final Map<String, IfdTag> exifData = await readExifFromBytes(bytes);

    // ── Check 1: EXIF data must exist ──
    if (exifData.isEmpty) {
      throw RealityViolationException(
        'Image lacks EXIF data entirely. '
        'ForgeVault only accepts verified photographs with hardware metadata.',
      );
    }

    // ── Check 2: Scan for AI-generation software tags ──
    final softwareTag = exifData['Image Software']?.printable ?? '';
    final description = exifData['Image ImageDescription']?.printable ?? '';
    final artist = exifData['Image Artist']?.printable ?? '';
    final userComment = exifData['EXIF UserComment']?.printable ?? '';

    final combinedMeta = '$softwareTag $description $artist $userComment'
        .toLowerCase();

    for (final aiTag in _aiSoftwareTags) {
      if (combinedMeta.contains(aiTag)) {
        throw RealityViolationException(
          'AI-generated image detected (software: "$aiTag"). '
          'ForgeVault only accepts verified reality — no synthetic content.',
        );
      }
    }

    // ── Check 3: Must have at least one hardware EXIF field ──
    final foundHardwareFields = <String>[];
    for (final field in _hardwareExifFields) {
      if (exifData.containsKey(field)) {
        foundHardwareFields.add(field);
      }
    }

    if (foundHardwareFields.isEmpty) {
      throw RealityViolationException(
        'Image has EXIF data but no hardware camera fields '
        '(Make, Model, DateTime, etc.). This may be a screenshot, '
        'download, or processed image. ForgeVault requires verified '
        'photographs from a physical camera or phone.',
      );
    }

    // ── Passed all checks ──
    return ExifVerificationResult(
      cameraMake: exifData['Image Make']?.printable,
      cameraModel: exifData['Image Model']?.printable,
      dateTimeOriginal: exifData['EXIF DateTimeOriginal']?.printable,
      software: softwareTag.isNotEmpty ? softwareTag : null,
      hardwareFieldCount: foundHardwareFields.length,
    );
  }

  /// Quick check — returns true if the image would pass verification.
  Future<bool> isVerified(File imageFile) async {
    try {
      await verify(imageFile);
      return true;
    } on RealityViolationException {
      return false;
    }
  }
}

/// Result of a successful EXIF verification.
class ExifVerificationResult {
  final String? cameraMake;
  final String? cameraModel;
  final String? dateTimeOriginal;
  final String? software;
  final int hardwareFieldCount;

  ExifVerificationResult({
    this.cameraMake,
    this.cameraModel,
    this.dateTimeOriginal,
    this.software,
    required this.hardwareFieldCount,
  });

  @override
  String toString() =>
      'ExifVerified(make: $cameraMake, model: $cameraModel, '
      'date: $dateTimeOriginal, hwFields: $hardwareFieldCount)';
}

/// Thrown when an image fails Reality Guard verification.
///
/// The caller (VacuumScreen) should display a prominent error modal
/// with a Matte Crimson drop zone and the violation message.
class RealityViolationException implements Exception {
  final String message;
  RealityViolationException(this.message);

  @override
  String toString() => 'RealityViolationException: $message';
}
