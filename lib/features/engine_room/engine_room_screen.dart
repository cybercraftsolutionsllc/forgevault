import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/api_key_service.dart';
import '../../core/services/forge_api_client.dart';
import '../../core/services/revenuecat_service.dart';
import '../../providers/providers.dart';
import '../../theme/theme.dart';

/// The Engine Room — BYOK API Key Management.
///
/// Allows users to securely input API keys for Grok, Claude, and Gemini.
/// Keys are stored in the OS hardware keychain via flutter_secure_storage.
/// Live Spark validation pings the API to verify the key works.
class EngineRoomScreen extends ConsumerStatefulWidget {
  const EngineRoomScreen({super.key});

  @override
  ConsumerState<EngineRoomScreen> createState() => _EngineRoomScreenState();
}

class _EngineRoomScreenState extends ConsumerState<EngineRoomScreen>
    with TickerProviderStateMixin {
  final ApiKeyService _keyService = ApiKeyService();
  final ForgeApiClient _apiClient = ForgeApiClient(keyService: ApiKeyService());

  // State per provider
  final Map<LlmProvider, TextEditingController> _controllers = {};
  final Map<LlmProvider, _KeyState> _keyStates = {};
  final Map<LlmProvider, bool> _isEditing = {};
  final Map<LlmProvider, AnimationController> _pulseControllers = {};
  bool _biometricsEnabled = false;

  // Local Node-specific controllers
  final TextEditingController _localBaseUrlController = TextEditingController(
    text: 'http://localhost:11434/v1',
  );
  final TextEditingController _localModelController = TextEditingController(
    text: 'llama3.2',
  );

  // Custom Provider-specific controllers
  final TextEditingController _customBaseUrlController =
      TextEditingController();
  final TextEditingController _customModelController = TextEditingController();
  final TextEditingController _customApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final provider in LlmProvider.values) {
      _controllers[provider] = TextEditingController();
      _keyStates[provider] = _KeyState.empty;
      _isEditing[provider] = false;
      _pulseControllers[provider] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
    }
    _loadExistingKeys();
    _loadBiometricPref();
  }

  Future<void> _loadExistingKeys() async {
    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (key != null && key.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _controllers[provider]!.text = key;
          _keyStates[provider] = _KeyState.saved;
        });
      }
    }
    // Pre-fill local node config
    final localUrl = await _keyService.getLocalBaseUrl();
    final localModel = await _keyService.getLocalModel();
    if (localUrl != null && localUrl.isNotEmpty) {
      _localBaseUrlController.text = localUrl;
    }
    if (localModel != null && localModel.isNotEmpty) {
      _localModelController.text = localModel;
    }
    // Pre-fill custom provider config
    final customUrl = await _keyService.getCustomBaseUrl();
    final customModel = await _keyService.getCustomModel();
    final customKey = await _keyService.getKey(LlmProvider.custom);
    if (customUrl != null && customUrl.isNotEmpty) {
      _customBaseUrlController.text = customUrl;
    }
    if (customModel != null && customModel.isNotEmpty) {
      _customModelController.text = customModel;
    }
    if (customKey != null && customKey.isNotEmpty) {
      _customApiKeyController.text = customKey;
    }
    // Silently validate all saved keys on boot so green indicators appear
    _revalidateAllKeys(showSnackBar: false);
  }

  /// Force re-read all keys and re-validate via Live Spark HTTP ping.
  Future<void> _revalidateAllKeys({bool showSnackBar = true}) async {
    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (!mounted) return;
      if (key == null || key.isEmpty) {
        setState(() {
          _keyStates[provider] = _KeyState.empty;
          _controllers[provider]!.clear();
        });
        continue;
      }
      // Force refresh the text field
      _controllers[provider]!.text = key;
      setState(() => _keyStates[provider] = _KeyState.validating);

      try {
        final result = await _apiClient.validateKey(provider, key);
        if (!mounted) return;

        switch (result) {
          case ValidationResult.valid:
            setState(() => _keyStates[provider] = _KeyState.valid);
            _pulseControllers[provider]!.repeat(reverse: true);
          case ValidationResult.invalid:
            setState(() => _keyStates[provider] = _KeyState.invalid);
        }
      } catch (_) {
        if (!mounted) return;
        _controllers[provider]!.clear();
        await _keyService.deleteKey(provider);
        setState(() => _keyStates[provider] = _KeyState.invalid);
      }
    }

    if (!mounted || !showSnackBar) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All keys re-validated',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: VaultColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final pulse in _pulseControllers.values) {
      pulse.dispose();
    }
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.settings_suggest_rounded,
              color: VaultColors.phosphorGreen,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'ENGINE ROOM',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: VaultColors.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        backgroundColor: VaultColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // ── Security Warning Banner ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VaultColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: VaultColors.phosphorGreenDim.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.amber.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SECURELY STORE YOUR API KEYS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keys are encrypted locally inside your hardware '
                        'keystore. They cannot be recovered if you uninstall '
                        'the app, lose your Master PIN, or fail to export a '
                        'backup.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: VaultColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Provider Cards
          for (final provider in LlmProvider.values) ...[
            _buildProviderCard(provider),
            const SizedBox(height: 16),
          ],

          // ── Scan Keystore Button (below provider cards) ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _revalidateAllKeys,
              icon: const Icon(Icons.security_update_good_rounded, size: 20),
              label: Text(
                'SCAN KEYSTORE & VERIFY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.greenAccent, width: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildInfoFooter(),

          const SizedBox(height: 24),

          // ── Biometric Unlock Toggle ──
          _buildBiometricToggle(),

          const SizedBox(height: 24),

          // ── Legal ──
          Divider(color: VaultColors.border, thickness: 0.5),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              size: 20,
              color: VaultColors.textMuted,
            ),
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: VaultColors.textSecondary,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new,
              size: 14,
              color: VaultColors.textMuted,
            ),
            onTap: () => launchUrl(
              Uri.parse('https://craftedcybersolutions.com/privacy.html'),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: VaultColors.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: VaultDecorations.frostedGlass(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: VaultColors.phosphorGreenDim,
                ),
                child: const Icon(
                  Icons.key_rounded,
                  color: VaultColors.phosphorGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bring Your Own Key',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: VaultColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connect cloud LLMs for deep synthesis',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: VaultColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: VaultColors.primary.withValues(alpha: 0.2),
              border: Border.all(color: VaultColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: VaultColors.primaryLight,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keys are stored in your device\'s hardware keychain. '
                    'They never leave this device.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: VaultColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(LlmProvider provider) {
    final state = _keyStates[provider]!;
    final isEditing = _isEditing[provider]!;
    final controller = _controllers[provider]!;
    final pulseController = _pulseControllers[provider]!;

    // Glow color based on state
    Color stateColor;
    IconData stateIcon;
    String stateLabel;
    switch (state) {
      case _KeyState.empty:
        stateColor = VaultColors.textMuted;
        stateIcon = Icons.circle_outlined;
        stateLabel = 'Not configured';
      case _KeyState.saved:
        stateColor = VaultColors.warning;
        stateIcon = Icons.circle;
        stateLabel = 'Key saved · Not validated';
      case _KeyState.validating:
        stateColor = VaultColors.warning;
        stateIcon = Icons.sync;
        stateLabel = 'Validating...';
      case _KeyState.valid:
        stateColor = VaultColors.phosphorGreen;
        stateIcon = Icons.check_circle;
        stateLabel = 'Live Spark ✓';
      case _KeyState.invalid:
        stateColor = VaultColors.destructive;
        stateIcon = Icons.error;
        stateLabel = 'Invalid key';
    }

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final glowIntensity = state == _KeyState.valid
            ? 0.08 + (pulseController.value * 0.06)
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: state == _KeyState.valid
                  ? VaultColors.phosphorGreenDim
                  : VaultColors.border,
              width: state == _KeyState.valid ? 1.0 : 0.5,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF121212), Color(0xFF0F0F0F)],
            ),
            boxShadow: state == _KeyState.valid
                ? [
                    BoxShadow(
                      color: VaultColors.phosphorGreen.withValues(
                        alpha: glowIntensity,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: stateColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    IconData(
                      provider.iconCodePoint,
                      fontFamily: 'MaterialIcons',
                    ),
                    color: stateColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: VaultColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stateIcon, color: stateColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      stateLabel,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: stateColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // API Key input / masked display (skip for Custom — has its own fields)
            if (provider != LlmProvider.custom &&
                (isEditing || state == _KeyState.empty)) ...[
              // Input mode
              TextField(
                controller: controller,
                obscureText: true,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: VaultColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: provider == LlmProvider.localNode
                      ? 'API key (optional for local nodes)'
                      : 'Paste your ${provider.displayName} API key…',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: VaultColors.textMuted,
                  ),
                  filled: true,
                  fillColor: VaultColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: VaultColors.phosphorGreenDim,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.content_paste_rounded,
                      size: 18,
                      color: VaultColors.textMuted,
                    ),
                    onPressed: () async {
                      final data = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );
                      if (data?.text != null) {
                        controller.text = data!.text!;
                      }
                    },
                  ),
                ),
              ),

              // Local Node: Base URL + Model Name fields
              if (provider == LlmProvider.localNode) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _localBaseUrlController,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: VaultColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'http://localhost:11434/v1',
                    labelText: 'Base URL',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: VaultColors.textMuted,
                    ),
                    hintStyle: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: VaultColors.textMuted.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: VaultColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VaultColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VaultColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: VaultColors.phosphorGreenDim,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _localModelController,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: VaultColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'llama3.2',
                    labelText: 'Model Name',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: VaultColors.textMuted,
                    ),
                    hintStyle: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: VaultColors.textMuted.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: VaultColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VaultColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: VaultColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: VaultColors.phosphorGreenDim,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],

            // Custom Provider: Always-editable fields (outside API key block)
            if (provider == LlmProvider.custom) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _customBaseUrlController,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: VaultColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'https://api.together.xyz/v1/chat/completions',
                  labelText: 'Custom Base URL',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: VaultColors.textMuted,
                  ),
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: VaultColors.textMuted.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: VaultColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: VaultColors.phosphorGreenDim,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customModelController,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: VaultColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'meta-llama/Llama-3-70b',
                  labelText: 'Custom Model Name',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: VaultColors.textMuted,
                  ),
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: VaultColors.textMuted.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: VaultColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: VaultColors.phosphorGreenDim,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customApiKeyController,
                obscureText: true,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: VaultColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'sk-...',
                  labelText: 'Custom API Key',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: VaultColors.textMuted,
                  ),
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: VaultColors.textMuted.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: VaultColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: VaultColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: VaultColors.phosphorGreenDim,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Save Custom Config button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state == _KeyState.validating
                          ? null
                          : () => _saveAndValidate(provider),
                      icon: state == _KeyState.validating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VaultColors.phosphorGreenDim,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 16),
                      label: Text(
                        state == _KeyState.validating
                            ? 'Validating…'
                            : 'Save Custom Config',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaultColors.primary,
                        foregroundColor: VaultColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Save & Validate button (non-custom providers)
            if (provider != LlmProvider.custom) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state == _KeyState.validating
                          ? null
                          : () => _saveAndValidate(provider),
                      icon: state == _KeyState.validating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: VaultColors.phosphorGreen,
                              ),
                            )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        state == _KeyState.validating
                            ? 'Validating…'
                            : 'Save & Live Spark',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VaultColors.primary,
                        foregroundColor: VaultColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        setState(() => _isEditing[provider] = false);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: VaultColors.textMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Masked key display (only for non-custom providers with saved keys)
            if (provider != LlmProvider.custom &&
                state != _KeyState.empty &&
                state != _KeyState.validating &&
                !isEditing) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: VaultColors.background,
                  border: Border.all(
                    color: state == _KeyState.valid
                        ? VaultColors.phosphorGreenDim
                        : state == _KeyState.invalid
                        ? VaultColors.destructive.withValues(alpha: 0.4)
                        : VaultColors.border,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state == _KeyState.valid
                          ? Icons.check_circle_outline_rounded
                          : state == _KeyState.invalid
                          ? Icons.error_outline_rounded
                          : Icons.lock_outline_rounded,
                      size: 14,
                      color: state == _KeyState.valid
                          ? VaultColors.phosphorGreen
                          : state == _KeyState.invalid
                          ? VaultColors.destructive
                          : VaultColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ApiKeyService.maskKey(controller.text),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: VaultColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    // Edit button
                    InkWell(
                      onTap: () {
                        setState(() => _isEditing[provider] = true);
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: VaultColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    InkWell(
                      onTap: () => _deleteKey(provider),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: VaultColors.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Get API Key link (hidden for Local Node and Custom)
            if (provider != LlmProvider.localNode &&
                provider != LlmProvider.custom)
              InkWell(
                onTap: () => _openKeyUrl(provider),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 13,
                        color: VaultColors.primaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Get ${provider.displayName} API Key →',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: VaultColors.primaryLight,
                          decoration: TextDecoration.underline,
                          decorationColor: VaultColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: VaultColors.surfaceVariant.withValues(alpha: 0.5),
        border: Border.all(color: VaultColors.borderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: VaultColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.upload_file_rounded,
            'Vacuum ingests your file and encrypts it locally',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.bolt_rounded,
            'The Forge sends extracted text to your chosen cloud LLM',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.rate_review_rounded,
            'You review the AI\'s extraction before committing',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.delete_forever_rounded,
            'Approve & the original file is cryptographically destroyed',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: VaultColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: VaultColors.textMuted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ──

  Future<void> _saveAndValidate(LlmProvider provider) async {
    final key = _controllers[provider]!.text.trim();
    if (provider != LlmProvider.localNode &&
        provider != LlmProvider.custom &&
        key.isEmpty) {
      return;
    }

    setState(() => _keyStates[provider] = _KeyState.validating);

    // Save local/custom config first (base URL, model)
    if (provider == LlmProvider.localNode) {
      final baseUrl = _localBaseUrlController.text.trim();
      final model = _localModelController.text.trim();
      if (baseUrl.isNotEmpty) await _keyService.saveLocalBaseUrl(baseUrl);
      if (model.isNotEmpty) await _keyService.saveLocalModel(model);
    } else if (provider == LlmProvider.custom) {
      final baseUrl = _customBaseUrlController.text.trim();
      final model = _customModelController.text.trim();
      if (baseUrl.isNotEmpty) await _keyService.saveCustomBaseUrl(baseUrl);
      if (model.isNotEmpty) await _keyService.saveCustomModel(model);
    }

    // Live Spark validation — validate BEFORE persisting key
    try {
      final result = await _apiClient.validateKey(provider, key);

      if (!mounted) return;

      // Validation passed — NOW save the key
      if (provider == LlmProvider.localNode) {
        if (key.isNotEmpty) await _keyService.saveKey(provider, key);
      } else if (provider == LlmProvider.custom) {
        final customKey = _customApiKeyController.text.trim();
        if (customKey.isNotEmpty) {
          await _keyService.saveKey(provider, customKey);
        }
      } else {
        await _keyService.saveKey(provider, key);
      }

      switch (result) {
        case ValidationResult.valid:
          setState(() => _keyStates[provider] = _KeyState.valid);
          _pulseControllers[provider]!.repeat(reverse: true);
          _isEditing[provider] = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: VaultColors.phosphorGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${provider.displayName} Live Spark — Connection verified!',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ],
              ),
              backgroundColor: VaultColors.primary,
            ),
          );

        case ValidationResult.invalid:
          setState(() => _keyStates[provider] = _KeyState.invalid);
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_rounded,
                    color: VaultColors.destructiveLight,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${provider.displayName} key validation failed. Check your key.',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ],
              ),
              backgroundColor: VaultColors.destructive,
            ),
          );
      }
    } catch (e) {
      // Validation threw — clear the invalid key from text field & storage
      if (!mounted) return;
      _controllers[provider]!.clear();
      await _keyService.deleteKey(provider);
      setState(() => _keyStates[provider] = _KeyState.invalid);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${provider.displayName}: $e',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: VaultColors.destructive,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _deleteKey(LlmProvider provider) async {
    await _keyService.deleteKey(provider);
    _pulseControllers[provider]!.stop();
    _pulseControllers[provider]!.reset();
    setState(() {
      _controllers[provider]!.clear();
      _keyStates[provider] = _KeyState.empty;
      _isEditing[provider] = false;
    });
  }

  Future<void> _openKeyUrl(LlmProvider provider) async {
    final uri = Uri.parse(provider.keyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Biometric Preference ──

  Future<void> _loadBiometricPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _biometricsEnabled = prefs.getBool('useBiometrics') ?? false,
      );
    }
  }

  Widget _buildBiometricToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VaultColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: VaultColors.phosphorGreen.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: VaultColors.phosphorGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Biometric Unlock',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.textPrimary,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _biometricsEnabled,
                activeTrackColor: VaultColors.phosphorGreen,
                onChanged: (value) => _toggleBiometrics(value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              'Use FaceID, TouchID, or Fingerprint to unlock '
              'your vault without entering your PIN.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: VaultColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometrics(bool enable) async {
    // PRO Gate
    final isPro = RevenueCatService().isProNotifier.value;
    if (!isPro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biometric Unlock is a PRO feature. Upgrade to enable.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: VaultColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final prefs = await SharedPreferences.getInstance();

    if (enable) {
      // Authenticate with biometrics before enabling
      try {
        final localAuth = LocalAuthentication();
        final didAuth = await localAuth.authenticate(
          localizedReason: 'Verify your identity to enable biometric unlock',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
        if (!didAuth) return; // User cancelled or failed

        // Save the current master PIN to SecureStorage
        final masterPin = ref.read(masterPinProvider);
        if (masterPin == null || masterPin.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No active PIN session. Unlock your vault first.',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: Colors.red.shade900,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          return;
        }

        await storage.write(key: 'biometric_pin', value: masterPin);
        await prefs.setBool('useBiometrics', true);
        if (mounted) setState(() => _biometricsEnabled = true);
      } on PlatformException {
        // Biometric auth not available or failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Biometric authentication failed or unavailable.',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade900,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } else {
      // Disable: remove stored PIN and flag
      await storage.delete(key: 'biometric_pin');
      await prefs.setBool('useBiometrics', false);
      if (mounted) setState(() => _biometricsEnabled = false);
    }
  }
}

enum _KeyState { empty, saved, validating, valid, invalid }
