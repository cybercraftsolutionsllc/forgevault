import 'package:flutter/foundation.dart';

/// The Blast Shield — global safety configuration.
///
/// When [isSafeMode] is true (debug builds by default):
/// - PurgeService bypasses real file deletion and key destruction
/// - Files are moved to `vitavault_debug_trash/` instead of destroyed
/// - A visible "SAFE MODE" watermark badge appears on the UI
/// - developer.log outputs warnings for every would-be destructive action
///
/// In release builds, isSafeMode is automatically false and the full
/// cryptographic erasure pipeline activates.
const bool isSafeMode = kDebugMode;
