import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_service.dart';
import 'forge_prompt.dart';
import 'no_api_key_exception.dart';

/// Dynamic HTTP client that routes synthesis requests to cloud LLM APIs.
///
/// Supports Grok (xAI), Claude (Anthropic), Gemini (Google),
/// OpenRouter, Groq, DeepSeek, and Mistral.
/// Each provider endpoint forces structured JSON output via
/// provider-specific mechanisms.
class ForgeApiClient {
  /// ── System Prompt ──
  /// Uses the canonical ForgePrompt.systemPrompt, which contains the
  /// full 55-field JSON schema with all ledger keys (career, medical,
  /// assets, relationalWeb, psyche) and 19 strict routing rules.
  static String get _forgeSystemPrompt => ForgePrompt.systemPrompt;
  final ApiKeyService _keyService;
  final http.Client _httpClient;
  final Duration _timeout;

  ForgeApiClient({
    required ApiKeyService keyService,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 90),
  }) : _keyService = keyService,
       _httpClient = httpClient ?? http.Client(),
       _timeout = timeout;

  /// Synthesize extracted text using the first available cloud provider.
  ///
  /// Priority: Grok → Claude → Gemini (matches user-configurable order).
  /// Returns raw JSON string matching the ForgeVault schema.
  Future<String> synthesize(String extractedText, {String? vaultState}) async {
    final prompt = _buildPrompt(extractedText, vaultState: vaultState);

    // Try providers in priority order
    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (provider == LlmProvider.localNode) {
        final url = await _keyService.getLocalBaseUrl();
        if (url == null || url.isEmpty) continue;
      } else if (provider == LlmProvider.custom) {
        final url = await _keyService.getCustomBaseUrl();
        if (url == null || url.isEmpty) continue;
      } else {
        if (key == null || key.isEmpty) continue;
      }

      // Key found — call MUST succeed or throw the real error.
      return await _callProvider(provider, key ?? '', prompt);
    }

    throw NoApiKeyException();
  }

  /// Synthesize using a specific provider.
  Future<String> synthesizeWith(
    LlmProvider provider,
    String extractedText, {
    String? vaultState,
  }) async {
    final key = await _keyService.getKey(provider);
    if (key == null || key.isEmpty) {
      throw ForgeApiException(
        'No API key configured for ${provider.displayName}.',
      );
    }

    final prompt = _buildPrompt(extractedText, vaultState: vaultState);
    return _callProvider(provider, key, prompt);
  }

  /// Ask the Nexus — conversational LLM call using Isar context.
  ///
  /// Unlike [synthesize], this does NOT enforce JSON output.
  /// Returns natural language text for the chat UI.
  Future<String> askNexus({
    required String query,
    required String context,
  }) async {
    final systemPrompt =
        'You are the ForgeVault Nexus, an empathetic, highly analytical AI '
        'assistant. Use the following encrypted user data context to answer '
        'the user\'s query. Reply in standard conversational text/markdown. '
        'DO NOT output JSON.\n\n'
        'DELETION PROTOCOL: If the user explicitly asks you to remove, delete, '
        'or forget specific data from their vault (e.g., "remove Master Electrician", '
        '"delete my old address"), you MUST append a command tag at the very end '
        'of your response for EACH item to remove:\n'
        '<DELETE>Exact string to remove</DELETE>\n'
        'You may include multiple <DELETE> tags. The string inside should match '
        'the stored value closely (case-insensitive substring matching will be used). '
        'Do NOT use <DELETE> tags unless the user explicitly requests removal.\n\n'
        'User Context:\n$context';

    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      // For localNode, the API key is optional — check base URL instead
      if (provider == LlmProvider.localNode) {
        final url = await _keyService.getLocalBaseUrl();
        if (url == null || url.isEmpty) continue;
      } else if (provider == LlmProvider.custom) {
        final url = await _keyService.getCustomBaseUrl();
        if (url == null || url.isEmpty) continue;
      } else {
        if (key == null || key.isEmpty) continue;
      }

      // Key found — call MUST succeed or throw the real error.
      switch (provider) {
        case LlmProvider.localNode:
          final baseUrl =
              await _keyService.getLocalBaseUrl() ??
              'http://localhost:11434/v1';
          final model = await _keyService.getLocalModel() ?? 'llama3.2';
          return _askNexusOpenAICompat(
            key ?? '',
            systemPrompt,
            query,
            '$baseUrl/chat/completions',
            model,
            'Local Node',
            timeout: const Duration(seconds: 120),
          );
        case LlmProvider.grok:
          return _askNexusGrok(key!, systemPrompt, query);
        case LlmProvider.claude:
          return _askNexusClaude(key!, systemPrompt, query);
        case LlmProvider.gemini:
          return _askNexusGemini(key!, systemPrompt, query);
        case LlmProvider.openRouter:
          return _askNexusOpenAICompat(
            key!,
            systemPrompt,
            query,
            'https://openrouter.ai/api/v1/chat/completions',
            'openrouter/auto',
            'OpenRouter',
          );
        case LlmProvider.groq:
          return _askNexusOpenAICompat(
            key!,
            systemPrompt,
            query,
            'https://api.groq.com/openai/v1/chat/completions',
            'llama-3.3-70b-versatile',
            'Groq',
          );
        case LlmProvider.deepSeek:
          return _askNexusOpenAICompat(
            key!,
            systemPrompt,
            query,
            'https://api.deepseek.com/chat/completions',
            'deepseek-chat',
            'DeepSeek',
          );
        case LlmProvider.mistral:
          return _askNexusOpenAICompat(
            key!,
            systemPrompt,
            query,
            'https://api.mistral.ai/v1/chat/completions',
            'mistral-large-latest',
            'Mistral',
          );
        case LlmProvider.custom:
          final baseUrl = await _keyService.getCustomBaseUrl() ?? '';
          final model = await _keyService.getCustomModel() ?? 'gpt-3.5-turbo';
          return _askNexusOpenAICompat(
            key ?? '',
            systemPrompt,
            query,
            baseUrl,
            model,
            'Custom',
          );
      }
    }

    throw NoApiKeyException();
  }

  /// Validate an API key with two-phase validation:
  /// 1. Prefix format check (throws on mismatch).
  /// 2. HTTP GET to the provider's models endpoint.
  ///
  /// Returns [ValidationResult.valid] if the API returns 200.
  /// Throws [Exception] for all other status codes and prefix mismatches.
  Future<ValidationResult> validateKey(
    LlmProvider provider,
    String apiKey,
  ) async {
    // ── Phase 1: Prefix format validation ──
    _validateKeyPrefix(provider, apiKey);

    // ── Phase 2: HTTP endpoint validation ──
    try {
      switch (provider) {
        case LlmProvider.localNode:
          final baseUrl =
              await _keyService.getLocalBaseUrl() ??
              'http://localhost:11434/v1';
          return await _validateOpenAICompat(apiKey, '$baseUrl/models');
        case LlmProvider.grok:
          return await _validateGrok(apiKey);
        case LlmProvider.claude:
          return await _validateClaude(apiKey);
        case LlmProvider.gemini:
          return await _validateGemini(apiKey);
        case LlmProvider.openRouter:
          return await _validateOpenAICompat(
            apiKey,
            'https://openrouter.ai/api/v1/models',
          );
        case LlmProvider.groq:
          return await _validateOpenAICompat(
            apiKey,
            'https://api.groq.com/openai/v1/models',
          );
        case LlmProvider.deepSeek:
          return await _validateOpenAICompat(
            apiKey,
            'https://api.deepseek.com/models',
          );
        case LlmProvider.mistral:
          return await _validateOpenAICompat(
            apiKey,
            'https://api.mistral.ai/v1/models',
          );
        case LlmProvider.custom:
          final baseUrl = await _keyService.getCustomBaseUrl() ?? '';
          final modelsUrl = baseUrl.endsWith('/chat/completions')
              ? baseUrl.replaceFirst('/chat/completions', '/models')
              : '$baseUrl/models';
          return await _validateOpenAICompat(apiKey, modelsUrl);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      return ValidationResult.invalid;
    }
  }

  /// Validate key prefix format for known providers.
  /// Throws [Exception] if the key does not match.
  void _validateKeyPrefix(LlmProvider provider, String apiKey) {
    switch (provider) {
      case LlmProvider.grok:
        if (!apiKey.startsWith('xai-')) {
          throw Exception(
            'Invalid Key Format: Grok keys must start with "xai-"',
          );
        }
      case LlmProvider.claude:
        if (!apiKey.startsWith('sk-ant-')) {
          throw Exception(
            'Invalid Key Format: Anthropic keys must start with "sk-ant-"',
          );
        }
      case LlmProvider.gemini:
        if (!apiKey.startsWith('AIza')) {
          throw Exception(
            'Invalid Key Format: Gemini keys must start with "AIza"',
          );
        }
      case LlmProvider.openRouter:
      case LlmProvider.groq:
      case LlmProvider.deepSeek:
      case LlmProvider.mistral:
        if (!apiKey.startsWith('sk-')) {
          throw Exception(
            'Invalid Key Format: ${provider.displayName} keys must start with "sk-"',
          );
        }
      case LlmProvider.localNode:
      case LlmProvider.custom:
        break; // no prefix requirement
    }
  }

  void dispose() {
    _httpClient.close();
  }

  /// Build the user-facing prompt from extracted text.
  static String _buildPrompt(String extractedText, {String? vaultState}) {
    return ForgePrompt.buildPrompt(extractedText, vaultState: vaultState);
  }

  // ── Provider Routing ──

  Future<String> _callProvider(
    LlmProvider provider,
    String apiKey,
    String prompt,
  ) async {
    switch (provider) {
      case LlmProvider.localNode:
        final baseUrl =
            await _keyService.getLocalBaseUrl() ?? 'http://localhost:11434/v1';
        final model = await _keyService.getLocalModel() ?? 'llama3.2';
        return _callOpenAICompat(
          apiKey,
          prompt,
          '$baseUrl/chat/completions',
          model,
          'Local Node',
          timeout: const Duration(seconds: 120),
        );
      case LlmProvider.grok:
        return _callGrok(apiKey, prompt);
      case LlmProvider.claude:
        return _callClaude(apiKey, prompt);
      case LlmProvider.gemini:
        return _callGemini(apiKey, prompt);
      case LlmProvider.openRouter:
        return _callOpenAICompat(
          apiKey,
          prompt,
          'https://openrouter.ai/api/v1/chat/completions',
          'openrouter/auto',
          'OpenRouter',
        );
      case LlmProvider.groq:
        return _callOpenAICompat(
          apiKey,
          prompt,
          'https://api.groq.com/openai/v1/chat/completions',
          'llama-3.3-70b-versatile',
          'Groq',
        );
      case LlmProvider.deepSeek:
        return _callOpenAICompat(
          apiKey,
          prompt,
          'https://api.deepseek.com/chat/completions',
          'deepseek-chat',
          'DeepSeek',
        );
      case LlmProvider.mistral:
        return _callOpenAICompat(
          apiKey,
          prompt,
          'https://api.mistral.ai/v1/chat/completions',
          'mistral-large-latest',
          'Mistral',
        );
      case LlmProvider.custom:
        final baseUrl = await _keyService.getCustomBaseUrl() ?? '';
        final model = await _keyService.getCustomModel() ?? 'gpt-3.5-turbo';
        return _callOpenAICompat(apiKey, prompt, baseUrl, model, 'Custom');
    }
  }

  // ── Grok (xAI) ──
  // Uses OpenAI-compatible API at api.x.ai
  // Forces JSON via response_format: { "type": "json_object" }

  Future<String> _callGrok(String apiKey, String prompt) async {
    final response = await _httpClient
        .post(
          Uri.parse('https://api.x.ai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'grok-3-mini',
            'messages': [
              {'role': 'system', 'content': _forgeSystemPrompt},
              {'role': 'user', 'content': prompt},
            ],
            'response_format': {'type': 'json_object'},
            'temperature': 0.2,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Grok',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) throw ForgeApiException('Grok returned no choices.');
    return (choices[0]['message']['content'] as String).trim();
  }

  Future<ValidationResult> _validateGrok(String apiKey) async {
    final response = await _httpClient
        .get(
          Uri.parse('https://api.x.ai/v1/models'),
          headers: {'Authorization': 'Bearer $apiKey'},
        )
        .timeout(const Duration(seconds: 10));
    return _interpretStatusCode(response.statusCode);
  }

  // ── Claude (Anthropic) ──
  // Uses Messages API at api.anthropic.com
  // Forces JSON via strict system prompt instructions

  Future<String> _callClaude(String apiKey, String prompt) async {
    final response = await _httpClient
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-sonnet-4-20250514',
            'max_tokens': 8192,
            'system': _forgeSystemPrompt,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Claude',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List<dynamic>;
    if (content.isEmpty) throw ForgeApiException('Claude returned no content.');
    return (content[0]['text'] as String).trim();
  }

  Future<ValidationResult> _validateClaude(String apiKey) async {
    final response = await _httpClient
        .get(
          Uri.parse('https://api.anthropic.com/v1/models'),
          headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
        )
        .timeout(const Duration(seconds: 10));
    return _interpretStatusCode(response.statusCode);
  }

  // ── Gemini (Google) ──
  // Uses generativeLanguage API
  // Forces JSON via response_mime_type: "application/json"

  Future<String> _callGemini(String apiKey, String prompt) async {
    final response = await _httpClient
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-2.0-flash:generateContent?key=$apiKey',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': '$_forgeSystemPrompt\n\n---\n\n$prompt'},
                ],
              },
            ],
            'generationConfig': {
              'responseMimeType': 'application/json',
              'temperature': 0.2,
            },
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Gemini',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>;
    if (candidates.isEmpty) {
      throw ForgeApiException('Gemini returned no candidates.');
    }
    final parts = candidates[0]['content']['parts'] as List<dynamic>;
    return (parts[0]['text'] as String).trim();
  }

  Future<ValidationResult> _validateGemini(String apiKey) async {
    final response = await _httpClient
        .get(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
          ),
        )
        .timeout(const Duration(seconds: 10));
    return _interpretStatusCode(response.statusCode);
  }

  // ── OpenAI-Compatible Providers (OpenRouter, Groq, DeepSeek, Mistral) ──
  // All use the standard OpenAI chat/completions format with Bearer auth.

  Future<String> _callOpenAICompat(
    String apiKey,
    String prompt,
    String endpoint,
    String model,
    String providerName, {
    Duration? timeout,
  }) async {
    final response = await _httpClient
        .post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': _forgeSystemPrompt},
              {'role': 'user', 'content': prompt},
            ],
            'response_format': {'type': 'json_object'},
            'temperature': 0.2,
          }),
        )
        .timeout(timeout ?? _timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        providerName,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw ForgeApiException('$providerName returned no choices.');
    }
    return (choices[0]['message']['content'] as String).trim();
  }

  Future<ValidationResult> _validateOpenAICompat(
    String apiKey,
    String modelsEndpoint,
  ) async {
    final response = await _httpClient
        .get(
          Uri.parse(modelsEndpoint),
          headers: {'Authorization': 'Bearer $apiKey'},
        )
        .timeout(const Duration(seconds: 10));
    return _interpretStatusCode(response.statusCode);
  }

  /// Interpret an HTTP status code into a [ValidationResult].
  ///
  /// 200 → valid.
  /// All other codes → throw.
  static ValidationResult _interpretStatusCode(int statusCode) {
    if (statusCode == 200) return ValidationResult.valid;
    throw Exception('API Error: Status Code $statusCode');
  }

  // ── Nexus-Specific Provider Methods ──
  // These use conversational prompts and do NOT enforce JSON output.

  Future<String> _askNexusGrok(
    String apiKey,
    String systemPrompt,
    String query,
  ) async {
    final response = await _httpClient
        .post(
          Uri.parse('https://api.x.ai/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'grok-3-mini',
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': query},
            ],
            'temperature': 0.7,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Grok',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) throw ForgeApiException('Grok returned no choices.');
    return (choices[0]['message']['content'] as String).trim();
  }

  Future<String> _askNexusClaude(
    String apiKey,
    String systemPrompt,
    String query,
  ) async {
    final response = await _httpClient
        .post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-sonnet-4-20250514',
            'max_tokens': 4096,
            'system': systemPrompt,
            'messages': [
              {'role': 'user', 'content': query},
            ],
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Claude',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List<dynamic>;
    if (content.isEmpty) throw ForgeApiException('Claude returned no content.');
    return (content[0]['text'] as String).trim();
  }

  Future<String> _askNexusGemini(
    String apiKey,
    String systemPrompt,
    String query,
  ) async {
    final response = await _httpClient
        .post(
          Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-2.0-flash:generateContent?key=$apiKey',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': '$systemPrompt\n\n---\n\n$query'},
                ],
              },
            ],
            'generationConfig': {'temperature': 0.7},
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        'Gemini',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>;
    if (candidates.isEmpty) {
      throw ForgeApiException('Gemini returned no candidates.');
    }
    final parts = candidates[0]['content']['parts'] as List<dynamic>;
    return (parts[0]['text'] as String).trim();
  }

  // ── Nexus OpenAI-Compatible (shared by OpenRouter, Groq, DeepSeek, Mistral) ──

  Future<String> _askNexusOpenAICompat(
    String apiKey,
    String systemPrompt,
    String query,
    String endpoint,
    String model,
    String providerName, {
    Duration? timeout,
  }) async {
    final response = await _httpClient
        .post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': query},
            ],
            'temperature': 0.7,
          }),
        )
        .timeout(timeout ?? _timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException.fromResponse(
        response.statusCode,
        response.body,
        providerName,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>;
    if (choices.isEmpty) {
      throw ForgeApiException('$providerName returned no choices.');
    }
    return (choices[0]['message']['content'] as String).trim();
  }
}

class ForgeApiException implements Exception {
  final String message;
  ForgeApiException(this.message);

  /// Factory: intercept overloaded server codes and return clean messages.
  factory ForgeApiException.fromResponse(
    int statusCode,
    String body,
    String providerName,
  ) {
    switch (statusCode) {
      case 429:
        return ForgeApiException(
          'Rate Limited: $providerName is throttling requests. '
          'Wait a moment and try again, or switch engines in the Engine Room.',
        );
      case 500:
        return ForgeApiException(
          'Server Error: $providerName is experiencing internal errors. '
          'This is on their end — try again shortly or switch providers.',
        );
      case 529:
        return ForgeApiException(
          'API Overloaded: $providerName is currently at capacity. '
          'Please try again in a few minutes or switch engines.',
        );
      case 503:
        return ForgeApiException(
          'Service Unavailable: $providerName is temporarily down. '
          'Try again shortly or switch providers in the Engine Room.',
        );
      default:
        return ForgeApiException(
          '$providerName error $statusCode: ${body.length > 200 ? body.substring(0, 200) : body}',
        );
    }
  }

  @override
  String toString() => message;
}

/// Result of an API key validation attempt.
enum ValidationResult {
  /// Key is valid and the API responded with 200.
  valid,

  /// Key is invalid — any non-200 response.
  invalid,
}
