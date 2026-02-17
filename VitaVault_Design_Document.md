🗄️ VitaVault: Master Architecture & Design Specification (v2.0)
Date: February 17, 2026
Founding Architects: User & Grok 4.20 / Gemini 3 (Antigravity System)
Target Environment: Google Antigravity IDE (Multi-Agent Workspace)
Primary Architecture: Flutter/Dart (Cross-Platform Native)

1. Executive Summary & Core Philosophy
Tagline: Your Private Life Vacuum & Living Bio Forge.
Mission: VitaVault is a 100% offline, cross-platform digital sanctuary. It ingests the chaotic, fragmented data of a user's life (documents, notes, real photos, emails), uses local AI to synthesize it into a clean, updatable "Living Life Bio," and cryptographically destroys the raw originals.
The "Why": To create a centralized, impenetrable vault where users can organize highly sensitive personal reality and trauma, allowing them to instantly explain their history to AI, therapists, or lawyers without endlessly retyping their past or risking cloud data breaches.

🛑 Strict Architectural Directives for Antigravity Agents:
NO CLOUD / ZERO TRUST: Do not include Firebase, AWS, telemetry, or crash reporting. Network requests are strictly limited to localhost (Ollama) or explicit local network syncs.

RAW CODE ONLY: Do not use visual builders. Generate highly optimized, raw Dart/Flutter code. Use Native MethodChannels for hardware-level OS operations.

DO NO HARM TO HARDWARE: Do not implement Gutmann or multi-pass overwrite algorithms. Rely strictly on Cryptographic Erasure (Ephemeral In-App Encryption) to bypass SSD wear-leveling while guaranteeing complete mathematical data destruction.

REALITY ENFORCEMENT: Strict real-photo only policy. No AI-generated imagery allowed; the application must preserve the absolute truth of the user's history.

2. Technology Stack & Dependencies
Agents must utilize the following stack for implementation:

Core Framework: Flutter (Dart). Target platforms: iOS, Android, macOS, Windows, Linux.

Database Engine: isar (NoSQL, lightning-fast, native Dart support, AES-256 database encryption at rest).

State Management: flutter_riverpod.

Security & Authentication: local_auth (FaceID, TouchID, Windows Hello) + Master PIN fallback.

File Handling & Ingestion: file_picker, desktop_drop, path_provider.

OCR & Extraction: google_mlkit_text_recognition (runs entirely on-device).

Image Forensics: tflite_flutter (running a lightweight local GAN/Fake-detection model) + EXIF validation.

Local AI / Synthesis Engine (The Forge):

Desktop/Linux: Direct HTTP REST client querying localhost:11434 (Ollama running local models).

Mobile: Google AI Edge SDK interfacing natively with on-device Gemini Nano.

Native Bridges: Swift (iOS/macOS), Kotlin (Android), C++ (Windows/Linux) via Flutter MethodChannels for secure sandboxing and OS-level file deletion prompts.

3. The Core Loop: Vacuum → Forge → Purge (State Machine)
This is the fundamental operational loop. Agents must implement this as a strict, fail-safe state machine.

Phase A: Ingest (The Vacuum)
Drop Zone: User drags/drops or selects files via OS intents.

Format Detection: The IngestionService auto-detects and categorizes: PDFs, .docx, .eml/.mbox, Markdown, images (JPEG/PNG/HEIC), and audio memos.

Live Capture Mode: In-app camera/microphone interface that hard-codes unalterable GPS and Timestamp watermarks into the EXIF data.

Phase B: Cryptographic Sandboxing (Security Upgrade)
System generates a Single-Use Ephemeral AES-256 Key in RAM.

The ingested raw file is instantly copied into a hidden, app-level storage directory and encrypted with this key.

VitaVault triggers a native OS prompt: "VitaVault requires permission to permanently delete the original unencrypted file from your device." User confirms, and the OS handles the recycle bin/trash removal.

VitaVault is now holding the only existing copy of the data, locked in the encrypted sandbox.

Phase C: Verify & Extract
Image Verification: Images pass through the TFLite anomaly detector. If AI-generation artifacts or EXIF tampering are detected, ingestion is aborted and flagged.

Extraction Pipeline:

Images/Scans run through google_mlkit_text_recognition.

Audio notes run through a lightweight local Whisper.cpp implementation.

Docs/Emails are parsed for raw text using native Dart parsers.

Phase D: Synthesize (The Forge)
LLM Processing: Extracted text is sent to the local LLM (Ollama/Nano).

System Prompt Directive: "You are the VitaVault Forge. Analyze this newly ingested user data. Extract troubles, goals, financial data, and timeline events. Output a strict JSON object matching the VitaVault Schema. Flag any contradictions with the existing database state."

Database Merge: The parsed JSON is merged into the encrypted isar database. Isar creates a snapshot of the prior state to allow for version history rollbacks.

Phase E: Destruct (The Purge)
Once the Forge successfully writes the synthesized data to Isar, VitaVault permanently deletes the Single-Use Ephemeral AES-256 Key from RAM.

The encrypted sandboxed file is deleted from the filesystem.

Result: The raw file instantly becomes mathematically unrecoverable digital dust. Zero wear-leveling damage to the user's SSD.

An immutable entry is written to the encrypted AuditLog.

4. Isar Database Schema Definitions (The Living Bio)
Agents must scaffold the following Isar Collections exactly as defined to ensure the Local AI can reliably read and write to the exact same structure.

Dart
@collection
class CoreIdentity {
  Id id = Isar.autoIncrement;
  late String fullName;
  DateTime? dateOfBirth;
  late String location; // e.g., Lancaster, PA
  List<String>? immutableTraits;
  late DateTime lastUpdated;
  int completenessScore = 0; // 0-100
}

@collection
class TimelineEvent {
  Id id = Isar.autoIncrement;
  @Index()
  late DateTime eventDate;
  late String title;
  late String description;
  late String category; // Health, Relationship, Career, Legal
  int emotionalImpactScore = 1; // 1-10 scale
  bool isVerified = false; // True if backed by Vacuumed document/photo
}

@collection
class Trouble {
  Id id = Isar.autoIncrement;
  late String title;
  late String detailText;
  late String category;
  int severity = 1; // 1-10 scale
  bool isResolved = false;
  late DateTime dateIdentified;
  List<String>? relatedEntities; 
}

@collection
class FinanceRecord {
  Id id = Isar.autoIncrement;
  late String assetOrDebtName;
  late double amount;
  late bool isDebt;
  String? notes;
  late DateTime lastUpdated;
}

@collection
class RelationshipNode {
  Id id = Isar.autoIncrement;
  late String personName;
  late String relationType;
  int trustLevel = 1; // 1-10 scale
  String? recentConflictOrSupport;
}

@collection
class AuditLog {
  Id id = Isar.autoIncrement;
  @Index()
  late DateTime timestamp;
  late String action; // "VACUUM_STARTED", "PURGE_COMPLETE", "FORGE_SYNTHESIS"
  late String fileHashDestroyed;
}
(Agent Note: Also scaffold collections for HealthProfile, Goal, and HabitVice following this pattern).

5. UI/UX & Design Language (The Dark Forest Vault)
The interface must feel secure, premium, impenetrable, and calming. No bright, harsh colors. Animations should feel heavy and mechanical.

Backgrounds: Matte Black (#0A0A0A), Sub-panels Deep Charcoal (#121212).

Primary Accent: Glowing Forest Green (#1B4332, #2D6A4F).

Highlight/Success: Phosphor Green (#39FF14 with low opacity).

Destructive Action (Purge): Matte Crimson (#780000).

Typography: Google Fonts Inter for UI clarity, JetBrains Mono for data-heavy audit logs. Playfair Display for Bio headers to give it a "memoir" feel.

Textures: Subtle metallic gradients on cards. Minimalist borders (0.5px opacity 0.2 green). Heavy use of Cupertino frosted-glass blur over dark backgrounds.

Core Views to Scaffold:
Biometric Gate (auth_screen.dart): Pure black screen, centered metallic vault icon. Prompts for FaceID/TouchID/PIN before decrypting Isar.

Home Dashboard (home_screen.dart):

Top: Progress ring showing "Life Bio Completeness" (Glowing Green).

Middle: "Quick AI Query" text input box.

Bottom: Horizontal scrolling cards (Recent Vacuums, Money Snapshot, Trouble Alerts).

Vacuum Hub (vacuum_screen.dart): Massive dashed-border drop zone. Animated green pulsing when files are dragged over. Live progress bars for Extract → Forge → Purge.

My Bio Viewer (bio_viewer_screen.dart): Expandable accordion list mapping to the Isar collections (Identity, Troubles, Goals, Health, etc.). Include a dedicated "Verified Real Photo Gallery."

AI Chat Console (oracle_chat_screen.dart): A private conversational UI. The local LLM is pre-loaded with a RAG (Retrieval-Augmented Generation) context of the user's Isar DB. (e.g., User asks: "Show me my 2026 money troubles.")

6. Security Protocols & Export Systems
App Lifecycle Security (Panic Blur): If the app is minimized, pushed to the background, or the screen locks, the app must immediately purge decrypted text from RAM, blur the UI using BackdropFilter, and drop back to the Biometric Gate via Flutter's WidgetsBindingObserver.

OS-Level Privacy: Implement native flags to disable OS-level screenshots and screen recording on mobile (FLAG_SECURE on Android, screen capture prevention on iOS).

One-Tap Anonymized Exports: While VitaVault is a black hole for raw data, the forged output is entirely owned by the user. Provide three strict export templates:

Grok Mode: Generates an anonymized JSON/Markdown string optimized specifically to be pasted into external LLMs (Grok, Gemini) as a system prompt. Personally Identifiable Information (PII) like SSNs, real names, or exact addresses are automatically masked.

Therapist PDF: Filters out financial data and passwords; outputs a clinically formatted PDF focusing on Timeline, Troubles, Habits, and Health history via the pdf package.

Legal Full Export: Generates an immutable, timestamped PDF dump of all verified facts, financial records, and the cryptographic audit log.

[END OF DOCUMENT]