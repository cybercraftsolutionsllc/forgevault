import 'package:flutter/services.dart';

/// Bridge to Google AI Edge SDK for on-device Gemini Nano inference.
///
/// Uses a MethodChannel to communicate with native Kotlin (Android) code
/// that interfaces with the Google AI Edge SDK.
///
/// Falls back to Ollama if Gemini Nano is not available.
class GeminiNanoBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.vitavault/gemini_nano',
  );

  /// Check if Gemini Nano is available on this device.
  ///
  /// Returns true only on Android devices with the AI Edge SDK installed.
  Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on MissingPluginException {
      // Not on Android or native side not set up
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Generate text from a prompt using Gemini Nano.
  ///
  /// The [systemPrompt] is prepended to the user prompt to guide
  /// the model's behavior (e.g., the Forge system prompt).
  Future<String> generate({
    required String prompt,
    String? systemPrompt,
  }) async {
    try {
      final fullPrompt = systemPrompt != null
          ? '$systemPrompt\n\n---\n\n$prompt'
          : prompt;

      final result = await _channel.invokeMethod<String>('generate', {
        'prompt': fullPrompt,
      });

      return result ?? '';
    } on MissingPluginException {
      throw GeminiNanoException(
        'Gemini Nano not available. Is the native bridge registered?',
      );
    } on PlatformException catch (e) {
      throw GeminiNanoException('Gemini Nano error: ${e.message}');
    }
  }

  /// Generate with structured JSON output.
  ///
  /// Wraps the prompt with instructions to output valid JSON
  /// matching the VitaVault schema format.
  Future<String> generateJson({
    required String prompt,
    String? systemPrompt,
  }) async {
    final jsonPrompt =
        '''
$prompt

IMPORTANT: Respond ONLY with a valid JSON object. No markdown, no explanation, no code fences.''';

    return generate(prompt: jsonPrompt, systemPrompt: systemPrompt);
  }
}

class GeminiNanoException implements Exception {
  final String message;
  GeminiNanoException(this.message);

  @override
  String toString() => 'GeminiNanoException: $message';
}
