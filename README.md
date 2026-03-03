# ForgeVault

**Offline-first, zero-trust encrypted personal vault.**

ForgeVault is a cross-platform mobile and desktop application that encrypts your entire digital life at rest using AES-256-GCM. All data stays on your device — no servers, no telemetry, no cloud dependency. Your vault only exists in plaintext while the app is unlocked; the moment you switch apps or lock your phone, ForgeVault encrypts and shreds the plaintext copy.

## Features

- **14 Ledger Categories** — Identity, Timeline, Finances, Health, Relationships, Career, Assets, Goals, Habits, Medical, Psyche, Custom, and more
- **Nexus AI** — RAG-powered assistant with full vault context for querying your data using natural language
- **Encrypted Backups** — AES-256-GCM `.forge` files with cross-device restore and PRO status sync
- **Biometric Unlock** — Fingerprint and face authentication
- **OCR Import** — Scan documents directly into ledger entries
- **Vacuum Engine** — Bulk-ingest data via AI-powered document parsing
- **Lifecycle Guard** — Instant blur overlay on app switch, auto-lock after 60 seconds, clipboard auto-wipe
- **Screenshot Prevention** — FLAG_SECURE on Android, capture prevention on iOS

## Security

| Layer | Implementation |
|-------|---------------|
| Encryption at rest | AES-256-GCM |
| Key derivation | PBKDF2-HMAC-SHA256 (210K iterations for backups) |
| License verification | Ed25519 cryptographic signatures (desktop) |
| Architecture | Zero-trust — no server, no telemetry, no cloud |
| Session protocol | Database encrypted on seal, plaintext shredded from disk |

## PRO Features

- Portable encrypted backup exports
- Priority support
- All future PRO features included

## Platforms

| Platform | Status |
|----------|--------|
| Android | Available (Play Store + APK) |
| Windows | Available |
| iOS | Coming Soon |
| macOS | Coming Soon |
| Linux | Coming Soon |

## Tech Stack

- **Framework:** Flutter / Dart
- **Database:** Isar
- **Crypto:** AES-256-GCM, PBKDF2, Ed25519 (PointyCastle)
- **Subscriptions:** RevenueCat (mobile), Stripe (desktop)
- **AI:** OpenAI-compatible API with RAG context

## Building

```bash
# Android
flutter build apk --release --no-tree-shake-icons
flutter build appbundle --release --no-tree-shake-icons

# Windows
flutter build windows --release
```

## License

Proprietary — Cyber Craft Solutions, LLC
