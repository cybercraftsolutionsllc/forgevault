import 'dart:convert';

import 'package:http/http.dart' as http;

/// Local HTTP client for communicating with Ollama at localhost:11434.
///
/// Sends prompts to the /api/generate endpoint and streams
/// the response back as parsed JSON lines.
class OllamaClient {
  final String _baseUrl;
  final http.Client _httpClient;
  final Duration _timeout;

  OllamaClient({
    String baseUrl = 'http://localhost:11434',
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 120),
  }) : _baseUrl = baseUrl,
       _httpClient = httpClient ?? http.Client(),
       _timeout = timeout;

  /// Check if Ollama is running and reachable.
  Future<bool> isAvailable() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// List available models on the Ollama instance.
  Future<List<String>> listModels() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl/api/tags'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final models = json['models'] as List<dynamic>? ?? [];
      return models
          .map((m) => (m as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Generate text from a prompt using the specified model.
  ///
  /// Returns the complete generated response as a single string.
  /// The response is streamed internally and concatenated.
  Future<String> generate({
    required String model,
    required String prompt,
    String? systemPrompt,
    double temperature = 0.3,
    int? maxTokens,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      'stream': false, // We collect the full response
      'options': {
        'temperature': temperature,
        // ignore: use_null_aware_elements
        if (maxTokens != null) 'num_predict': maxTokens,
      },
    };

    if (systemPrompt != null) {
      body['system'] = systemPrompt;
    }

    final response = await _httpClient
        .post(
          Uri.parse('$_baseUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw OllamaException(
        'Ollama returned status ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['response'] as String? ?? '';
  }

  /// Generate with streaming — yields chunks as they arrive.
  Stream<String> generateStream({
    required String model,
    required String prompt,
    String? systemPrompt,
    double temperature = 0.3,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      'stream': true,
      'options': {'temperature': temperature},
    };

    if (systemPrompt != null) {
      body['system'] = systemPrompt;
    }

    final request = http.Request('POST', Uri.parse('$_baseUrl/api/generate'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(body);

    final streamedResponse = await _httpClient.send(request).timeout(_timeout);

    if (streamedResponse.statusCode != 200) {
      throw OllamaException(
        'Ollama stream returned status ${streamedResponse.statusCode}',
      );
    }

    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      // Each line is a JSON object
      for (final line in chunk.split('\n')) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final text = json['response'] as String? ?? '';
          if (text.isNotEmpty) yield text;
        } catch (_) {
          // Skip malformed lines
        }
      }
    }
  }

  /// Clean up the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}

class OllamaException implements Exception {
  final String message;
  OllamaException(this.message);

  @override
  String toString() => 'OllamaException: $message';
}
