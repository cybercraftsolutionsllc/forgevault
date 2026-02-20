import 'dart:io';

/// Developer utility — generates dummy files for testing the
/// Vacuum → Forge → Purge pipeline without real user data.
///
/// Files are written to the OS temporary directory and are safe to delete.
class TestDataGenerator {
  TestDataGenerator._();

  /// Generate a ~200-word fake journal entry about a landlord dispute.
  ///
  /// Contains extractable: 1 Trouble, 1 Goal, 1 Finance, 1 Relationship.
  static Future<File> generateFakeJournal() async {
    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}fake_journal.txt',
    );

    const content = '''
March 14, 2026 — Personal Journal

I can't believe what happened today with Mr. Henderson. I've been asking him to 
fix that busted heater in the living room for THREE MONTHS now, and he finally 
had the nerve to tell me he's deducting \$450 from my security deposit for "tenant 
negligence." TENANT NEGLIGENCE?! The thing was rusted through when I moved in! 
I have photos from move-in day that prove the coils were already corroded.

Honestly, this whole situation is making me sick to my stomach. I barely slept 
last night because the apartment was freezing — it got down to 48 degrees inside. 
Sarah said I should just call the housing authority and file a formal complaint, 
and honestly she's probably right. She's been a rock through all of this. I don't 
know what I'd do without her support.

I've made up my mind though. I'm moving out by December 2026. No more dealing 
with this slumlord and his excuses. I've been putting away a little money each 
month, and if I can keep saving at this rate, I should have enough for first and 
last month's rent on a decent place across town by the fall.

The fight is wearing me down. My anxiety has been through the roof. I had two 
panic attacks this week alone — one at work during a presentation, which was 
mortifying. I need to get my mental health under control. Maybe I should look 
into therapy again. The \$450 deduction is going to hurt though, I was counting 
on getting that deposit back to help fund the move.

At least the coffee was good today. Small victories.
''';

    await file.writeAsString(content);
    return file;
  }

  /// Generate a mock OCR'd medical bill from Lancaster General.
  ///
  /// Contains extractable: 1 Finance (debt), 1 Health data, 1 Timeline event.
  static Future<File> generateFakeMedicalBill() async {
    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}fake_medical_bill.md',
    );

    const content = '''
# LANCASTER GENERAL HOSPITAL
## Patient Statement of Account

**Date of Service:** February 28, 2026
**Account Number:** LGH-2026-88214
**Patient:** [REDACTED FOR TESTING]

---

### CHARGES:

| Service                          | Code    | Amount     |
|----------------------------------|---------|------------|
| Emergency Room Visit - Level 3   | 99283   | \$   680.00 |
| Diagnostic Imaging - Chest X-Ray | 71046   | \$   245.00 |
| Laboratory - Complete Blood Count| 85025   | \$   125.00 |
| Pharmacy - IV Fluids             | J7040   | \$    85.00 |
| Physician Fee - ER Attending     | 99283-25| \$    65.00 |
|                                  |         |            |
| **TOTAL CHARGES**                |         | **\$1,200.00** |

---

### INSURANCE APPLIED:
- Insurance Provider: NONE ON FILE
- Patient Responsibility: **\$1,200.00**

### DIAGNOSIS:
- Acute bronchitis, unspecified (J20.9)
- Chest pain, unspecified (R07.9)

### ATTENDING PHYSICIAN:
Dr. Maria Chen, MD — Emergency Medicine

---

*Payment due within 30 days. Contact our billing department at (717) 555-0142 
for payment plan options. Financial assistance applications available upon request.*

*THIS IS NOT A BILL — THIS IS A TESTING DOCUMENT*
''';

    await file.writeAsString(content);
    return file;
  }

  /// Generate the expected mock LLM JSON response for the fake journal.
  ///
  /// Used to mock LLM responses in integration tests so we don't hit real APIs.
  static String get mockJournalForgeResponse => '''
{
  "identity": null,
  "timelineEvents": [
    {
      "eventDate": "2026-03-14",
      "title": "Landlord Dispute Over Heater Repair",
      "description": "Mr. Henderson deducted \$450 from security deposit for alleged tenant negligence on a broken heater that was already corroded at move-in.",
      "category": "Legal",
      "emotionalImpactScore": 8,
      "isVerified": false
    }
  ],
  "troubles": [
    {
      "title": "Landlord dispute — broken heater and security deposit deduction",
      "detailText": "Mr. Henderson refusing to fix corroded heater for 3 months, then deducting \$450 from security deposit citing tenant negligence. Apartment dropped to 48°F. Photos from move-in day prove pre-existing damage.",
      "category": "Housing",
      "severity": 8,
      "isResolved": false,
      "dateIdentified": "2026-03-14",
      "relatedEntities": ["Mr. Henderson", "Sarah"]
    }
  ],
  "finances": [
    {
      "assetOrDebtName": "Security deposit deduction — heater repair",
      "amount": 450.0,
      "isDebt": true,
      "notes": "Deducted by landlord Mr. Henderson for alleged tenant negligence"
    }
  ],
  "relationships": [
    {
      "personName": "Mr. Henderson",
      "relationType": "Landlord",
      "trustLevel": 2,
      "recentConflictOrSupport": "Refusing to fix broken heater, deducted \$450 from deposit"
    },
    {
      "personName": "Sarah",
      "relationType": "Close friend or partner",
      "trustLevel": 9,
      "recentConflictOrSupport": "Supportive — suggested filing housing authority complaint"
    }
  ],
  "health": {
    "conditions": ["Anxiety disorder", "Panic attacks"],
    "medications": [],
    "allergies": [],
    "bloodType": null
  },
  "goals": [
    {
      "title": "Move out of current apartment",
      "category": "Personal",
      "description": "Leave current rental and find a decent place across town. Saving monthly for first and last month's rent.",
      "targetDate": "2026-12-01",
      "progress": 15
    }
  ],
  "habitsVices": [],
  "changelog": []
}
''';

  // ─────────────────────────────────────────────────────────────
  // Phase 8: Image test data for Reality Guard
  // ─────────────────────────────────────────────────────────────

  /// Generate a minimal dummy JPEG with mock EXIF data simulating a real camera.
  ///
  /// Contains Camera Make ("Canon"), Model ("Canon EOS R5"),
  /// DateTimeOriginal, and Software tags.
  ///
  /// This file will PASS Reality Guard verification.
  static Future<File> generateFakeReceipt() async {
    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}fake_receipt.jpg',
    );

    final exifBytes = _buildMinimalExifJpeg(
      make: 'Canon',
      model: 'Canon EOS R5',
      dateTimeOriginal: '2026:02:15 09:34:22',
      software: 'Canon Firmware 1.8.1',
    );

    await file.writeAsBytes(exifBytes);
    return file;
  }

  /// Generate a dummy JPEG with NO EXIF data (stripped metadata).
  ///
  /// This file will FAIL Reality Guard verification — simulates an
  /// AI-generated or heavily processed image with no camera origin.
  static Future<File> generateFakeAiImage() async {
    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}${Platform.pathSeparator}fake_AI_image.jpg',
    );

    // Minimal valid JPEG with only JFIF marker — no EXIF at all.
    final bytes = <int>[
      0xFF, 0xD8, // SOI
      0xFF, 0xE0, // APP0 JFIF
      0x00, 0x10, // Length = 16
      0x4A, 0x46, 0x49, 0x46, 0x00, // "JFIF\0"
      0x01, 0x01, // Version 1.1
      0x00, // Aspect ratio
      0x00, 0x01, // X density
      0x00, 0x01, // Y density
      0x00, 0x00, // Thumbnail
      0xFF, 0xDA, 0x00, 0x08, // SOS
      0x01, 0x01, 0x00, 0x00, 0x3F, 0x00,
      0x00, 0x00,
      0xFF, 0xD9, // EOI
    ];

    await file.writeAsBytes(bytes);
    return file;
  }

  // ── EXIF Binary Construction Helpers ──

  /// Build a minimal JPEG byte array with valid EXIF APP1 data.
  static List<int> _buildMinimalExifJpeg({
    required String make,
    required String model,
    required String dateTimeOriginal,
    String? software,
  }) {
    final bytes = <int>[];
    bytes.addAll([0xFF, 0xD8]); // SOI

    final tiffPayload = _buildTiffPayload(
      make: make,
      model: model,
      dateTimeOriginal: dateTimeOriginal,
      software: software,
    );

    bytes.addAll([0xFF, 0xE1]); // APP1 marker

    final app1Length = 2 + 6 + tiffPayload.length;
    bytes.addAll([(app1Length >> 8) & 0xFF, app1Length & 0xFF]);
    bytes.addAll([0x45, 0x78, 0x69, 0x66, 0x00, 0x00]); // "Exif\0\0"
    bytes.addAll(tiffPayload);

    // Minimal SOS + EOI
    bytes.addAll([0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00]);
    bytes.addAll([0x00, 0x00, 0xFF, 0xD9]);

    return bytes;
  }

  /// Build a minimal big-endian TIFF structure with IFD0 + EXIF sub-IFD.
  static List<int> _buildTiffPayload({
    required String make,
    required String model,
    required String dateTimeOriginal,
    String? software,
  }) {
    final buf = <int>[];

    // TIFF Header
    buf.addAll([0x4D, 0x4D]); // Big-endian "MM"
    buf.addAll([0x00, 0x2A]); // Magic 42
    buf.addAll([0x00, 0x00, 0x00, 0x08]); // IFD0 offset

    final hasSoftware = software != null && software.isNotEmpty;
    final ifd0TagCount = hasSoftware ? 4 : 3;
    final ifd0Size = 2 + 12 * ifd0TagCount + 4;
    final stringDataOffset = 8 + ifd0Size;

    final makeBytes = _asciiNull(make);
    final modelBytes = _asciiNull(model);
    final softwareBytes = hasSoftware ? _asciiNull(software) : <int>[];
    final dateBytes = _asciiNull(dateTimeOriginal);

    var cursor = stringDataOffset;
    final makeOffset = cursor;
    cursor += makeBytes.length;
    final modelOffset = cursor;
    cursor += modelBytes.length;
    int softwareOffset = 0;
    if (hasSoftware) {
      softwareOffset = cursor;
      cursor += softwareBytes.length;
    }

    final exifIfdOffset = cursor;
    final exifIfdSize = 2 + 12 + 4;
    final dateOffset = exifIfdOffset + exifIfdSize;

    // IFD0
    buf.addAll(_uint16(ifd0TagCount));
    buf.addAll(_ifdEntry(0x010F, 2, makeBytes.length, makeOffset));
    buf.addAll(_ifdEntry(0x0110, 2, modelBytes.length, modelOffset));
    if (hasSoftware) {
      buf.addAll(_ifdEntry(0x0131, 2, softwareBytes.length, softwareOffset));
    }
    buf.addAll(_ifdEntry(0x8769, 4, 1, exifIfdOffset));
    buf.addAll([0x00, 0x00, 0x00, 0x00]); // Next IFD = 0

    // String data
    buf.addAll(makeBytes);
    buf.addAll(modelBytes);
    if (hasSoftware) buf.addAll(softwareBytes);

    // EXIF sub-IFD
    buf.addAll(_uint16(1));
    buf.addAll(_ifdEntry(0x9003, 2, dateBytes.length, dateOffset));
    buf.addAll([0x00, 0x00, 0x00, 0x00]);

    buf.addAll(dateBytes);

    return buf;
  }

  static List<int> _ifdEntry(int tag, int type, int count, int valueOrOffset) =>
      [
        ..._uint16(tag),
        ..._uint16(type),
        ..._uint32(count),
        ..._uint32(valueOrOffset),
      ];

  static List<int> _uint16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
  static List<int> _uint32(int v) => [
    (v >> 24) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 8) & 0xFF,
    v & 0xFF,
  ];

  static List<int> _asciiNull(String s) => [...s.codeUnits, 0x00];
}
