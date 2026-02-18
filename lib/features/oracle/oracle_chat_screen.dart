import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/database/database_service.dart';
import '../../core/services/api_key_service.dart';
import '../../core/services/forge_api_client.dart';
import '../../core/services/local_rag_service.dart';
import '../../theme/theme.dart';
import 'mint_viewer_screen.dart';

/// Oracle Chat Console — private conversational UI with BYOK LLM.
///
/// Features:
/// - Dark Forest themed chat interface
/// - Blueprint Mint chips (Resume, LLM Context, Therapist Prep)
/// - Airlock Interceptor dialog before any data egress
/// - Automatic RAG context injection from Isar vault
/// - Long-form responses open in MintViewerScreen
class OracleChatScreen extends StatefulWidget {
  final ForgeApiClient? forgeClient;

  const OracleChatScreen({super.key, this.forgeClient});

  @override
  State<OracleChatScreen> createState() => _OracleChatScreenState();
}

// ─────────────────────────────────────────────────────────────
// Blueprint Definitions
// ─────────────────────────────────────────────────────────────

class _Blueprint {
  final String name;
  final String label;
  final IconData icon;
  final Color accentColor;
  final String prompt;

  const _Blueprint({
    required this.name,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.prompt,
  });
}

const _blueprints = [
  _Blueprint(
    name: 'resume',
    label: 'Mint Resume',
    icon: Icons.work_outline_rounded,
    accentColor: Color(0xFF64B5F6),
    prompt:
        'Generate a professional, ATS-friendly Markdown resume based on my '
        'career and education history. Use clean formatting with sections for '
        'Summary, Experience, Education, Skills, and Certifications. '
        'Optimize keyword density for applicant tracking systems.',
  ),
  _Blueprint(
    name: 'llm_context',
    label: 'Mint LLM Context',
    icon: Icons.psychology_outlined,
    accentColor: Color(0xFFCE93D8),
    prompt:
        'Generate a dense, comprehensive system prompt for an external AI '
        'assistant. Include my current goals, core identity traits, active '
        'technical skills, habits, and preferences. Format as a single '
        'copy-pasteable system prompt block optimized for Grok, Claude, or ChatGPT.',
  ),
  _Blueprint(
    name: 'therapist',
    label: 'Mint Therapist Prep',
    icon: Icons.healing_outlined,
    accentColor: Color(0xFF81C784),
    prompt:
        'Generate an objective clinical summary suitable for sharing with '
        'a therapist or mental health professional. Include: current troubles '
        'and stressors, relationship dynamics, health conditions, emotional '
        'patterns, and active life goals. Use professional clinical language '
        'and organize by domain.',
  ),
];

// ─────────────────────────────────────────────────────────────

class _OracleChatScreenState extends State<OracleChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  late final LocalRagService _ragService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _ragService = LocalRagService(DatabaseService.instance.db);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Blueprint Activation
  // ─────────────────────────────────────────────────────────────

  Future<void> _activateBlueprint(_Blueprint bp) async {
    // Build the appropriate context blob
    String contextBlob;
    switch (bp.name) {
      case 'resume':
        contextBlob = await _ragService.buildResumeContext();
      case 'llm_context':
        contextBlob = await _ragService.buildLlmContextExport();
      case 'therapist':
        contextBlob = await _ragService.buildTherapistContext();
      default:
        contextBlob = await _ragService.buildContextBlob(categories: []);
    }

    // Show Airlock Interceptor
    if (!mounted) return;
    final approved = await _showAirlockInterceptor(
      contextBlob: contextBlob,
      blueprintName: bp.label,
    );
    if (approved != true) return;

    // Add user message
    setState(() {
      _messages.add(
        _ChatMessage(text: '🎫 ${bp.label}', isUser: true, isBlueprint: true),
      );
      _isProcessing = true;
    });
    _scrollToBottom();

    // Build the full prompt with RAG context
    final fullPrompt = _ragService.wrapWithContext(
      userMessage: bp.prompt,
      contextBlob: contextBlob,
      blueprintInstruction: 'OUTPUT FORMAT: Markdown. Be comprehensive.',
    );

    // Send to LLM
    await _sendToLlm(fullPrompt, isBlueprint: true, blueprintTitle: bp.label);
  }

  // ─────────────────────────────────────────────────────────────
  // Free-Form Chat
  // ─────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isProcessing) return;

    _inputController.clear();

    // Build general RAG context
    final contextBlob = await _ragService.buildContextBlob(
      categories: [],
      includeIdentity: true,
      includeHealth: true,
      includeRelationships: true,
      includeFinances: true,
    );

    // Show Airlock Interceptor
    if (!mounted) return;
    final approved = await _showAirlockInterceptor(
      contextBlob: contextBlob,
      blueprintName: null,
    );
    if (approved != true) {
      // Restore the text if user cancels
      _inputController.text = text;
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isProcessing = true;
    });
    _scrollToBottom();

    final fullPrompt = _ragService.wrapWithContext(
      userMessage: text,
      contextBlob: contextBlob,
    );

    await _sendToLlm(fullPrompt);
  }

  Future<void> _sendToLlm(
    String prompt, {
    bool isBlueprint = false,
    String? blueprintTitle,
  }) async {
    try {
      // ── Dynamic LLM routing: check for ANY configured BYOK key ──
      final keyService = ApiKeyService();
      final activeProvider = await keyService.getFirstAvailableProvider();

      if (activeProvider == null) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text:
                  'Oracle requires a configured LLM provider.\n\n'
                  'Go to Engine Room → API Keys to connect Grok, Claude, or Gemini.',
              isUser: false,
              isError: true,
            ),
          );
          _isProcessing = false;
        });
        return;
      }

      if (!mounted) return;

      final client = ForgeApiClient(keyService: keyService);
      final response = await client.synthesize(prompt);

      setState(() {
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
            isLongForm: isBlueprint || response.length > 500,
            blueprintTitle: blueprintTitle,
          ),
        );
        _isProcessing = false;
      });
      _scrollToBottom();
    } catch (e) {
      developer.log(
        '\x1B[31m[ORACLE] LLM Error: $e\x1B[0m',
        name: 'OracleChat',
      );
      setState(() {
        _messages.add(
          _ChatMessage(text: 'Oracle Error: $e', isUser: false, isError: true),
        );
        _isProcessing = false;
      });
      // Surface exact error in SnackBar for immediate visibility
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Airlock Interceptor Dialog
  // ─────────────────────────────────────────────────────────────

  Future<bool?> _showAirlockInterceptor({
    required String contextBlob,
    required String? blueprintName,
  }) {
    final summary = _ragService.summarizeBlob(contextBlob);
    final totalItems = summary.values.fold<int>(0, (a, b) => a + b);
    final tokenEstimate = (contextBlob.length / 4).round();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8B4000), width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B00).withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Color(0xFFFF6B00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AIRLOCK INTERCEPTOR',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFFF6B00),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Data leaving the vault',
                    style: GoogleFonts.inter(
                      color: VaultColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blueprint badge
            if (blueprintName != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: VaultColors.primary.withValues(alpha: 0.2),
                  border: Border.all(
                    color: VaultColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '🎫 Blueprint: $blueprintName',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.primaryLight,
                  ),
                ),
              ),

            // Data manifest
            Text(
              'DATA MANIFEST',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: VaultColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in summary.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            _getManifestIcon(entry.key),
                            size: 14,
                            color: const Color(0xFFFF6B00),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: VaultColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${entry.value} ${entry.value == 1 ? "record" : "records"}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: VaultColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(color: Color(0xFF30363D), height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$totalItems records · ~$tokenEstimate tokens',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: const Color(0xFFFF6B00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Warning
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: VaultColors.destructive.withValues(alpha: 0.1),
                border: Border.all(
                  color: VaultColors.destructive.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: VaultColors.destructiveLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This data will be sent to your configured BYOK LLM '
                      'provider via encrypted API call.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: VaultColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'DENY',
              style: GoogleFonts.jetBrainsMono(
                color: VaultColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(ctx, true);
            },
            icon: const Icon(Icons.lock_open_rounded, size: 16),
            label: Text(
              'AUTHORIZE EGRESS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getManifestIcon(String key) {
    switch (key) {
      case 'identity':
        return Icons.person_rounded;
      case 'timeline':
        return Icons.timeline_rounded;
      case 'troubles':
        return Icons.warning_amber_rounded;
      case 'goals':
        return Icons.flag_rounded;
      case 'finances':
        return Icons.account_balance_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'relationships':
        return Icons.people_rounded;
      case 'habits':
        return Icons.loop_rounded;
      default:
        return Icons.data_object_rounded;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isProcessing
                    ? const Color(0xFFFF6B00)
                    : VaultColors.phosphorGreen,
                boxShadow: [
                  BoxShadow(
                    color:
                        (_isProcessing
                                ? const Color(0xFFFF6B00)
                                : VaultColors.phosphorGreen)
                            .withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ORACLE',
              style: GoogleFonts.jetBrainsMono(
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: VaultColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Blueprint Chips ──
          _buildBlueprintBar(),

          // ── Chat Messages ──
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _messages.length + (_isProcessing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isProcessing) {
                        return _buildTypingIndicator();
                      }
                      return _ChatBubble(
                        message: _messages[index],
                        onViewFull: _messages[index].isLongForm
                            ? () => _openMintViewer(_messages[index])
                            : null,
                      );
                    },
                  ),
          ),

          // ── Input Bar ──
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBlueprintBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: VaultColors.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: VaultColors.borderSubtle, width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _blueprints.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final bp = _blueprints[index];
          return GestureDetector(
            onTap: _isProcessing ? null : () => _activateBlueprint(bp),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: bp.accentColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: bp.accentColor.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(bp.icon, size: 14, color: bp.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    bp.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: bp.accentColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VaultColors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 32,
              color: VaultColors.primaryLight.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Private Oracle',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask questions about your life data\nor use a Blueprint to mint a document.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: VaultColors.textMuted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: VaultColors.surfaceVariant,
              border: Border.all(color: VaultColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security_rounded,
                  size: 14,
                  color: Color(0xFFFF6B00),
                ),
                const SizedBox(width: 8),
                Text(
                  'Airlock Interceptor protects every egress',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: VaultColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(bottomLeft: const Radius.circular(4)),
          color: VaultColors.surfaceVariant,
          border: Border.all(color: VaultColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: VaultColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Oracle is thinking...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: VaultColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        border: Border(
          top: BorderSide(color: VaultColors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: VaultColors.surfaceVariant,
                  border: Border.all(
                    color: VaultColors.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  enabled: !_isProcessing,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: VaultColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about your life data...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: VaultColors.textMuted,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isProcessing ? null : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: _isProcessing
                      ? VaultColors.surfaceVariant
                      : VaultColors.primary,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _isProcessing
                      ? VaultColors.textMuted
                      : VaultColors.phosphorGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMintViewer(_ChatMessage msg) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MintViewerScreen(
          content: msg.text,
          title: msg.blueprintTitle ?? 'Oracle Response',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Chat Models
// ─────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isBlueprint;
  final bool isLongForm;
  final bool isError;
  final String? blueprintTitle;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isBlueprint = false,
    this.isLongForm = false,
    this.isError = false,
    this.blueprintTitle,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final VoidCallback? onViewFull;

  const _ChatBubble({required this.message, this.onViewFull});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                color: message.isError
                    ? VaultColors.destructive.withValues(alpha: 0.15)
                    : isUser
                    ? VaultColors.primary
                    : VaultColors.surfaceVariant,
                border: isUser
                    ? null
                    : Border.all(
                        color: message.isError
                            ? VaultColors.destructive.withValues(alpha: 0.3)
                            : VaultColors.border,
                        width: 0.5,
                      ),
              ),
              child: Text(
                message.isLongForm && message.text.length > 300
                    ? '${message.text.substring(0, 300)}...'
                    : message.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: message.isError
                      ? const Color(0xFFFF6B6B)
                      : VaultColors.textPrimary,
                  fontWeight: message.isError
                      ? FontWeight.w600
                      : FontWeight.normal,
                  height: 1.5,
                ),
              ),
            ),

            // "View Full" button for long-form responses
            if (message.isLongForm && onViewFull != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: onViewFull,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: VaultColors.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: VaultColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: VaultColors.primaryLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'View Full · Export',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: VaultColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
