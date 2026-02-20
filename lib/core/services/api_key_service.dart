import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Supported cloud LLM providers for BYOK.
enum LlmProvider {
  grok(
    displayName: 'Grok',
    description: 'xAI\'s Grok — fast reasoning model',
    keyUrl: 'https://console.x.ai/keys',
    iconCodePoint: 0xe87b, // smart_toy
  ),
  claude(
    displayName: 'Claude',
    description: 'Anthropic\'s Claude — deep analysis',
    keyUrl: 'https://console.anthropic.com/settings/keys',
    iconCodePoint: 0xe873, // psychology
  ),
  gemini(
    displayName: 'Gemini',
    description: 'Google\'s Gemini — multimodal synthesis',
    keyUrl: 'https://aistudio.google.com/app/apikey',
    iconCodePoint: 0xe838, // auto_awesome
  ),
  openRouter(
    displayName: 'OpenRouter',
    description: 'Unified gateway — access 100+ models',
    keyUrl: 'https://openrouter.ai/keys',
    iconCodePoint: 0xe8f4, // router
  ),
  groq(
    displayName: 'Groq',
    description: 'Groq — ultra-fast LPU inference',
    keyUrl: 'https://console.groq.com/keys',
    iconCodePoint: 0xe8e8, // speed
  ),
  deepSeek(
    displayName: 'DeepSeek',
    description: 'DeepSeek — efficient reasoning model',
    keyUrl: 'https://platform.deepseek.com/',
    iconCodePoint: 0xef3e, // explore
  ),
  mistral(
    displayName: 'Mistral',
    description: 'Mistral AI — European frontier model',
    keyUrl: 'https://console.mistral.ai/api-keys/',
    iconCodePoint: 0xe3a5, // air
  );

  final String displayName;
  final String description;
  final String keyUrl;
  final int iconCodePoint;

  const LlmProvider({
    required this.displayName,
    required this.description,
    required this.keyUrl,
    required this.iconCodePoint,
  });
}

/// Manages secure storage of BYOK API keys via the OS hardware keychain.
///
/// - Android → EncryptedSharedPreferences (Android Keystore)
/// - iOS → Keychain Services
/// - Windows → Windows Credential Locker
/// - macOS → Keychain
/// - Linux → libsecret
class ApiKeyService {
  static const _keyPrefix = 'vitavault_api_key_';

  final FlutterSecureStorage _storage;

  ApiKeyService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  /// Save an API key for the given provider.
  Future<void> saveKey(LlmProvider provider, String apiKey) async {
    await _storage.write(key: _storageKey(provider), value: apiKey);
  }

  /// Retrieve an API key for the given provider.
  /// Returns null if no key is stored.
  Future<String?> getKey(LlmProvider provider) async {
    return _storage.read(key: _storageKey(provider));
  }

  /// Delete the API key for the given provider.
  Future<void> deleteKey(LlmProvider provider) async {
    await _storage.delete(key: _storageKey(provider));
  }

  /// Check if a key exists for the given provider.
  Future<bool> hasKey(LlmProvider provider) async {
    final key = await getKey(provider);
    return key != null && key.isNotEmpty;
  }

  /// Get the first available provider that has a stored key.
  /// Returns null if no keys are configured.
  Future<LlmProvider?> getFirstAvailableProvider() async {
    for (final provider in LlmProvider.values) {
      if (await hasKey(provider)) return provider;
    }
    return null;
  }

  /// Get all providers with their key status.
  Future<Map<LlmProvider, bool>> getAllKeyStatuses() async {
    final statuses = <LlmProvider, bool>{};
    for (final provider in LlmProvider.values) {
      statuses[provider] = await hasKey(provider);
    }
    return statuses;
  }

  /// Get the active (first available) provider by reading directly from
  /// the hardware keystore every time. NEVER returns a cached value.
  ///
  /// Alias for [getFirstAvailableProvider] — named for spec compliance.
  Future<LlmProvider?> getActiveProvider() async {
    for (final provider in LlmProvider.values) {
      final key = await _storage.read(key: _storageKey(provider));
      if (key != null && key.isNotEmpty) return provider;
    }
    return null;
  }

  /// Retrieve an API key by reading directly from the hardware keystore
  /// every time. NEVER returns a cached value.
  ///
  /// Named alias for [getKey] — named for spec compliance.
  Future<String?> getApiKey(LlmProvider provider) async {
    return _storage.read(key: _storageKey(provider));
  }

  /// Force-read ALL keys from the hardware keystore.
  ///
  /// Returns a map of provider → key (null if not stored).
  /// Used by the Engine Room's "SCAN KEYSTORE & VERIFY" button.
  Future<Map<LlmProvider, String?>> forceReadAllKeys() async {
    final result = <LlmProvider, String?>{};
    for (final provider in LlmProvider.values) {
      result[provider] = await _storage.read(key: _storageKey(provider));
    }
    return result;
  }

  /// Mask a key for display (show first 8 + last 4 chars).
  static String maskKey(String key) {
    if (key.length <= 12) return '••••••••';
    return '${key.substring(0, 8)}${'•' * (key.length - 12)}${key.substring(key.length - 4)}';
  }

  String _storageKey(LlmProvider provider) => '$_keyPrefix${provider.name}';
}
