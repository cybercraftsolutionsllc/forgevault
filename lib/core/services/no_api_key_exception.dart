/// Exception thrown when ForgeService is called with no API keys configured.
///
/// Used by the Vacuum pipeline to surface a user-friendly AlertDialog
/// prompting navigation to the Engine Room for key entry.
class NoApiKeyException implements Exception {
  final String message;

  const NoApiKeyException([
    this.message = 'No API keys configured. Go to Engine Room to add one.',
  ]);

  @override
  String toString() => 'NoApiKeyException: $message';
}
