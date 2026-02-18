import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/api_key_service.dart';
import '../../core/services/forge_api_client.dart';
import '../../core/services/vault_sync_service.dart';
import '../../features/settings/pro_upgrade_screen.dart';
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
  final VaultSyncService _syncService = VaultSyncService();

  // State per provider
  final Map<LlmProvider, TextEditingController> _controllers = {};
  final Map<LlmProvider, _KeyState> _keyStates = {};
  final Map<LlmProvider, bool> _isEditing = {};
  final Map<LlmProvider, AnimationController> _pulseControllers = {};

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
  }

  Future<void> _loadExistingKeys() async {
    for (final provider in LlmProvider.values) {
      final key = await _keyService.getKey(provider);
      if (key != null && key.isNotEmpty) {
        setState(() {
          _controllers[provider]!.text = key;
          _keyStates[provider] = _KeyState.saved;
        });
      }
    }
  }

  /// Force re-read all keys and re-validate via Live Spark HTTP ping.
  Future<void> _revalidateAllKeys() async {
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

      final result = await _apiClient.validateKey(provider, key);
      if (!mounted) return;

      switch (result) {
        case ValidationResult.valid:
        case ValidationResult.validWithWarning:
          setState(() => _keyStates[provider] = _KeyState.valid);
          _pulseControllers[provider]!.repeat(reverse: true);
        case ValidationResult.invalid:
          setState(() => _keyStates[provider] = _KeyState.invalid);
      }
    }

    if (!mounted) return;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: VaultColors.phosphorGreen),
            tooltip: 'Re-validate all keys',
            onPressed: _revalidateAllKeys,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 24),

          // Provider Cards
          for (final provider in LlmProvider.values) ...[
            _buildProviderCard(provider),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),
          _buildInfoFooter(),

          const SizedBox(height: 32),

          // ── Security & Sync Section ──
          _buildSecuritySyncSection(),
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

            // API Key input / masked display
            if (isEditing || state == _KeyState.empty) ...[
              // Input mode
              TextField(
                controller: controller,
                obscureText: true,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: VaultColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste your ${provider.displayName} API key…',
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
              const SizedBox(height: 12),
              // Save & Validate button
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
            ] else ...[
              // Masked key display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: VaultColors.background,
                  border: Border.all(color: VaultColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: VaultColors.textMuted,
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

            // Get API Key link
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
    if (key.isEmpty) return;

    setState(() => _keyStates[provider] = _KeyState.validating);

    // Save first
    await _keyService.saveKey(provider, key);

    // Live Spark validation
    final result = await _apiClient.validateKey(provider, key);

    if (!mounted) return;

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

      case ValidationResult.validWithWarning:
        // Key format is valid but account needs credits/billing.
        // Save anyway and show warning.
        setState(() => _keyStates[provider] = _KeyState.valid);
        _pulseControllers[provider]!.repeat(reverse: true);
        _isEditing[provider] = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFD600),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${provider.displayName}: Key format valid, but account '
                    'requires credits/billing.',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF5C4800),
            duration: const Duration(seconds: 5),
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

  // ── Security & Sync Section ──

  Widget _buildSecuritySyncSection() {
    final isPro = ref.watch(isProUnlockedProvider);
    final syncDir = ref.watch(syncDirectoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: VaultColors.phosphorGreenDim,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: VaultColors.phosphorGreen,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SECURITY & SYNC',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: VaultColors.textSecondary,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Vault Sync Tile
        _buildSettingsTile(
          icon: Icons.sync_lock_rounded,
          title: 'Vault Sync',
          subtitle: syncDir != null
              ? 'Sync directory configured'
              : 'Select a sync directory to begin',
          trailing: isPro
              ? PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: VaultColors.textMuted,
                    size: 20,
                  ),
                  color: VaultColors.surface,
                  onSelected: (value) async {
                    switch (value) {
                      case 'select':
                        final dir = await _syncService.selectSyncDirectory();
                        if (dir != null && mounted) {
                          ref.read(syncDirectoryProvider.notifier).state = dir;
                        }
                        break;
                      case 'export':
                        final pin = ref.read(masterPinProvider);
                        if (pin != null) {
                          final ok = await _syncService.exportVault(pin);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Vault exported successfully.'
                                      : 'Export failed — set sync directory first.',
                                ),
                                backgroundColor: ok
                                    ? VaultColors.primary
                                    : VaultColors.destructive,
                              ),
                            );
                          }
                        }
                        break;
                      case 'import':
                        final pin = ref.read(masterPinProvider);
                        if (pin != null) {
                          try {
                            final ok = await _syncService.importVault(pin);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Vault imported and merged.'
                                        : 'No vault file found.',
                                  ),
                                  backgroundColor: ok
                                      ? VaultColors.primary
                                      : VaultColors.destructive,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Import failed: $e'),
                                  backgroundColor: VaultColors.destructive,
                                ),
                              );
                            }
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'select',
                      child: Text('Select Sync Directory'),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Text('Export Vault'),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Text('Import & Merge'),
                    ),
                  ],
                )
              : _buildProBadge(),
          isActive: isPro && syncDir != null,
        ),

        const SizedBox(height: 12),

        // Upgrade to Pro Tile
        _buildSettingsTile(
          icon: isPro
              ? Icons.verified_user_rounded
              : Icons.workspace_premium_rounded,
          title: isPro ? 'Pro Active' : 'Upgrade to Pro',
          subtitle: isPro
              ? 'All fortress features unlocked'
              : 'Unlock Biometrics, Sync & more',
          trailing: isPro
              ? Icon(
                  Icons.check_circle_rounded,
                  color: VaultColors.phosphorGreen.withValues(alpha: 0.7),
                  size: 20,
                )
              : const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: VaultColors.textMuted,
                  size: 16,
                ),
          onTap: isPro
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProUpgradeScreen()),
                  );
                },
          isActive: isPro,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? VaultColors.phosphorGreenDim : VaultColors.border,
            width: isActive ? 1 : 0.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF121212), Color(0xFF0F0F0F)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isActive
                    ? VaultColors.primary.withValues(alpha: 0.3)
                    : VaultColors.surfaceVariant,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? VaultColors.phosphorGreen
                    : VaultColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VaultColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: VaultColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: VaultColors.primary.withValues(alpha: 0.3),
        border: Border.all(color: VaultColors.phosphorGreenDim, width: 0.5),
      ),
      child: Text(
        'PRO',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: VaultColors.phosphorGreen,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

enum _KeyState { empty, saved, validating, valid, invalid }
