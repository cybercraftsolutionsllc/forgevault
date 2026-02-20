import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_service.dart';
import 'no_api_key_exception.dart';

/// Dynamic HTTP client that routes synthesis requests to cloud LLM APIs.
///
/// Supports Grok (xAI), Claude (Anthropic), Gemini (Google),
/// OpenRouter, Groq, DeepSeek, and Mistral.
/// Each provider endpoint forces structured JSON output via
/// provider-specific mechanisms.
class ForgeApiClient {
  /// ── Hardcoded Master System Prompt ──
  /// Injected into every cloud LLM call. Strictly enforces JSON extraction
  /// with no conversational output. Provider-specific mechanisms
  /// (`response_format`, `responseMimeType`) provide additional enforcement.
  static const String _forgeSystemPrompt = '''
You are the ForgeVault Forge. You do not converse. You do not explain.
You extract structured data from raw user text and return ONLY a valid JSON
object. Any response that is not pure JSON will be rejected by the parser.

Extract the following categories from the provided text:
- timeline: dated events with emotional impact scores (1-10)
- troubles: active problems with severity scores (1-10)
- goals: aspirations with target dates and progress percentage
- finances: assets and debts with amounts
- relationships: people with trust levels (1-10)
- health: conditions, medications, allergies
- habitsVices: behavioral patterns

Return ONLY a valid JSON object matching this schema:
{
  "identity": { "fullName": "string|null", "dateOfBirth": "ISO8601|null", "location": "string|null", "immutableTraits": [] },
  "timelineEvents": [{ "id": integer_or_omit, "eventDate": "ISO8601", "title": "", "description": "", "category": "Health|Relationship|Career|Legal|Financial|Personal", "emotionalImpactScore": 1, "isVerified": false }],
  "troubles": [{ "id": integer_or_omit, "title": "", "detailText": "", "category": "", "severity": 1, "isResolved": false, "dateIdentified": "ISO8601", "relatedEntities": [] }],
  "finances": [{ "assetOrDebtName": "", "amount": 0.0, "isDebt": false, "notes": null }],
  "relationships": [{ "personName": "", "relationType": "", "trustLevel": 1, "recentConflictOrSupport": null }],
  "health": { "conditions": [], "medications": [], "allergies": [], "bloodType": null },
  "goals": [{ "id": integer_or_omit, "title": "", "category": "Personal", "description": null, "targetDate": null, "progress": 0 }],
  "habitsVices": [{ "id": integer_or_omit, "name": "", "isVice": false, "frequency": "Occasional", "severity": 1, "notes": null }],
  "changelog": []
}

Rules:
- ID MATCHING: To update an existing item, include its exact integer id. Omit id for new items.
- ALIASES & NAMES: Do NOT overwrite the user's primary name unless explicitly commanded.
- CHANGELOG: Output a changelog array explaining every modification.
- Output ONLY valid JSON. No markdown. No code fences. No explanation.
- Omit empty arrays. Set unknown fields to null.
- Dates in ISO 8601 format (YYYY-MM-DD).
- Preserve the user's own words when quoting emotional content.
''';
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
  Future<String> synthesize(String extractedText) async {
    final prompt = _buildPrompt(extractedText);

    // Try providers in priority order
    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (key == null || key.isEmpty) continue;

      // Key found — call MUST succeed or throw the real error.
      return await _callProvider(provider, key, prompt);
    }

    throw NoApiKeyException();
  }

  /// Synthesize using a specific provider.
  Future<String> synthesizeWith(
    LlmProvider provider,
    String extractedText,
  ) async {
    final key = await _keyService.getKey(provider);
    if (key == null || key.isEmpty) {
      throw ForgeApiException(
        'No API key configured for ${provider.displayName}.',
      );
    }

    final prompt = _buildPrompt(extractedText);
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
        'DO NOT output JSON.\n\nUser Context:\n$context';

    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (key == null || key.isEmpty) continue;

      // Key found — call MUST succeed or throw the real error.
      switch (provider) {
        case LlmProvider.grok:
          return _askNexusGrok(key, systemPrompt, query);
        case LlmProvider.claude:
          return _askNexusClaude(key, systemPrompt, query);
        case LlmProvider.gemini:
          return _askNexusGemini(key, systemPrompt, query);
        case LlmProvider.openRouter:
          return _askNexusOpenAICompat(
            key,
            systemPrompt,
            query,
            'https://openrouter.ai/api/v1/chat/completions',
            'openrouter/auto',
            'OpenRouter',
          );
        case LlmProvider.groq:
          return _askNexusOpenAICompat(
            key,
            systemPrompt,
            query,
            'https://api.groq.com/openai/v1/chat/completions',
            'llama-3.3-70b-versatile',
            'Groq',
          );
        case LlmProvider.deepSeek:
          return _askNexusOpenAICompat(
            key,
            systemPrompt,
            query,
            'https://api.deepseek.com/chat/completions',
            'deepseek-chat',
            'DeepSeek',
          );
        case LlmProvider.mistral:
          return _askNexusOpenAICompat(
            key,
            systemPrompt,
            query,
            'https://api.mistral.ai/v1/chat/completions',
            'mistral-large-latest',
            'Mistral',
          );
      }
    }

    throw NoApiKeyException();
  }

  /// Validate an API key by pinging the provider with a minimal request.
  ///
  /// Returns [ValidationResult.valid] if the API returns 200.
  /// Returns [ValidationResult.validWithWarning] if the API returns
  /// 400, 402, 403, or 429 (key format is correct, but account needs
  /// credits, billing, or has hit rate limits).
  /// Returns [ValidationResult.invalid] for all other failures.
  Future<ValidationResult> validateKey(
    LlmProvider provider,
    String apiKey,
  ) async {
    try {
      switch (provider) {
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
      }
    } catch (_) {
      return ValidationResult.invalid;
    }
  }

  void dispose() {
    _httpClient.close();
  }

  /// Build the user-facing prompt from extracted text.
  static String _buildPrompt(String extractedText) {
    return '## Newly Ingested Text to Analyze:\n$extractedText';
  }

  // ── Provider Routing ──

  Future<String> _callProvider(
    LlmProvider provider,
    String apiKey,
    String prompt,
  ) {
    switch (provider) {
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
      throw ForgeApiException(
        'Grok API error ${response.statusCode}: ${response.body}',
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
      throw ForgeApiException(
        'Claude API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List<dynamic>;
    if (content.isEmpty) throw ForgeApiException('Claude returned no content.');
    return (content[0]['text'] as String).trim();
  }

  Future<ValidationResult> _validateClaude(String apiKey) async {
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
            'max_tokens': 16,
            'messages': [
              {'role': 'user', 'content': 'Respond with: ok'},
            ],
          }),
        )
        .timeout(const Duration(seconds: 15));
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
      throw ForgeApiException(
        'Gemini API error ${response.statusCode}: ${response.body}',
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
    String providerName,
  ) async {
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
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException(
        '$providerName API error ${response.statusCode}: ${response.body}',
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
  /// 400, 402, 403, 429 → key format recognized, account needs credits.
  /// Everything else → invalid.
  static ValidationResult _interpretStatusCode(int statusCode) {
    if (statusCode == 200) return ValidationResult.valid;
    if (statusCode == 400 ||
        statusCode == 402 ||
        statusCode == 403 ||
        statusCode == 429) {
      return ValidationResult.validWithWarning;
    }
    return ValidationResult.invalid;
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
      throw ForgeApiException(
        'Grok API error ${response.statusCode}: ${response.body}',
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
      throw ForgeApiException(
        'Claude API error ${response.statusCode}: ${response.body}',
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
      throw ForgeApiException(
        'Gemini API error ${response.statusCode}: ${response.body}',
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
    String providerName,
  ) async {
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
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ForgeApiException(
        '$providerName API error ${response.statusCode}: ${response.body}',
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

  @override
  String toString() => 'ForgeApiException: $message';
}

/// Result of an API key validation attempt.
enum ValidationResult {
  /// Key is valid and the API responded with 200.
  valid,

  /// Key format is recognized (400/402/403/429), but the account
  /// needs credits, billing setup, or has hit rate limits.
  validWithWarning,

  /// Key is invalid — unrecognized or authentication failure.
  invalid,
}
