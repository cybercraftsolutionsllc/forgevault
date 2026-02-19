import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/database_service.dart';
import '../../theme/theme.dart';

/// Help Center — FAQ and debug tools.
///
/// Explains API key setup, Safe Mode, RAG Oracle, and Sync.
/// Includes a Factory Reset button (debug builds only).
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'How do I get API keys for the Forge?',
      answer:
          'Navigate to the Engine Room (bottom tab). Each AI provider '
          '(Grok, Claude, Gemini) has a "Get API Key" link that opens the '
          'respective developer portal. Sign up, generate a key, and paste '
          'it into ForgeVault. Keys are stored in your device\'s hardware '
          'keychain — they never leave this device.',
    ),
    _FaqItem(
      question: 'What is Safe Mode?',
      answer:
          'Safe Mode is automatically active in debug builds. When enabled, '
          'the Purge system moves files to a debug recovery folder instead '
          'of permanently destroying them. This protects you during development. '
          'In Release Mode, Safe Mode is disabled and the full cryptographic '
          'shredder is armed — file destruction is irreversible.',
    ),
    _FaqItem(
      question: 'How does the RAG Oracle work?',
      answer:
          'The Oracle is a Retrieval-Augmented Generation (RAG) chat interface. '
          'It queries your local Isar database to build a context window, '
          'then sends that context along with your question to your configured '
          'cloud AI (via your BYOK key). The AI synthesizes an answer grounded '
          'in YOUR data. An offline Ollama fallback is available if you run '
          'a local LLM server.',
    ),
    _FaqItem(
      question: 'How do I set up Vault Sync?',
      answer:
          'Vault Sync is a Pro feature. After upgrading, go to Engine Room → '
          'Security & Sync → Vault Sync. Select a sync directory (a local folder, '
          'USB drive, or cloud-synced folder like OneDrive/Dropbox). Export creates '
          'an AES-256-GCM encrypted bundle. Import decrypts and merges data '
          'using a newest-wins strategy. Zero-trust, zero-knowledge — the sync '
          'file is useless without your Master PIN.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(
          'HELP CENTER',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: VaultDecorations.frostedGlass(borderRadius: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: VaultColors.phosphorGreenDim,
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
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
                        'Frequently Asked Questions',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Everything you need to know about ForgeVault',
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
          ),

          const SizedBox(height: 20),

          // ── FAQ Items ──
          for (final faq in _faqs) ...[
            _FaqCard(faq: faq),
            const SizedBox(height: 12),
          ],

          // ── Factory Reset (debug only) ──
          if (kDebugMode) ...[
            const SizedBox(height: 32),
            const Divider(color: VaultColors.border, height: 1),
            const SizedBox(height: 16),

            Text(
              'DEBUG TOOLS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: VaultColors.textMuted,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: () => _confirmFactoryReset(context),
                icon: const Icon(
                  Icons.warning_amber_rounded,
                  color: VaultColors.destructive,
                  size: 18,
                ),
                label: Text(
                  'Factory Reset (Debug)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.destructive,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmFactoryReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Text(
          'Factory Reset',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: VaultColors.textPrimary,
          ),
        ),
        content: Text(
          'This will erase ALL data — shared preferences, database, '
          'and encryption keys. The app will restart in first-time '
          'onboarding mode.\n\nThis action is irreversible.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: VaultColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: VaultColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _performFactoryReset(context);
            },
            child: Text(
              'Reset Everything',
              style: GoogleFonts.inter(
                color: VaultColors.destructive,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performFactoryReset(BuildContext context) async {
    try {
      // 1. Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Wipe the Isar database
      final db = DatabaseService.instance;
      if (db.isOpen) {
        final isar = db.db;
        await isar.writeTxn(() async {
          await isar.clear();
        });
        await db.close();
      }

      // 3. Restart the app by popping to root and rebuilding
      if (context.mounted) {
        // Navigate to a fresh root, forcing rebuild
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Show confirmation before restart-like behavior
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Factory reset complete. Restart the app to begin onboarding.',
              style: GoogleFonts.inter(color: VaultColors.textPrimary),
            ),
            backgroundColor: VaultColors.destructive,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: VaultColors.destructive,
          ),
        );
      }
    }
  }
}

// ── Data Model ──

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

// ── FAQ Expandable Card ──

class _FaqCard extends StatefulWidget {
  final _FaqItem faq;

  const _FaqCard({required this.faq});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? VaultColors.phosphorGreenDim
                : VaultColors.border,
            width: _expanded ? 1 : 0.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF121212), Color(0xFF0F0F0F)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VaultColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: VaultColors.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.faq.answer,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: VaultColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
