import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/database_service.dart';
import '../../theme/theme.dart';

/// Help Center — FAQ and debug tools.
///
/// Explains API key setup, RAG Nexus, and Sync.
/// Includes a Factory Reset button (debug builds only).
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'What is ForgeVault?',
      answer:
          'ForgeVault is a zero-trust, local-first personal data vault. It '
          'extracts, categorizes, and securely stores your life data — identity, '
          'career, medical history, finances, relationships, and more — entirely '
          'on your device. No cloud account required, no telemetry, no ads.',
    ),
    _FaqItem(
      question: 'What does "Bring Your Own Key" (BYOK) mean?',
      answer:
          'BYOK means you supply your own API key for cloud AI services. '
          'ForgeVault never provides or proxies API keys. You generate a key '
          'from your chosen provider (Grok, Claude, Gemini, OpenRouter, Groq, '
          'DeepSeek, or Mistral), paste it into the Engine Room, and it\'s '
          'stored in your device\'s hardware keychain. Your key, your cost, '
          'your control — we never see it.',
    ),
    _FaqItem(
      question: 'How do I get API keys for the Forge?',
      answer:
          'Navigate to the Engine Room (bottom tab). Each AI provider card has '
          'a "Get API Key" link that opens the provider\'s developer dashboard. '
          'Sign up, generate a key, and paste it into ForgeVault. Keys are '
          'stored in your device\'s hardware keychain (Android Keystore, iOS '
          'Keychain, Windows Credential Locker) — they never leave this device.',
    ),
    _FaqItem(
      question: 'How does local-first architecture work?',
      answer:
          'All your data lives in an encrypted Isar database on your device. '
          'Documents are parsed locally using on-device text extraction — '
          'the raw file never leaves your phone or computer. Only the extracted '
          'text is sent to your chosen AI provider (via your BYOK key) for '
          'categorization. The AI response is parsed, you review it, and only '
          'then is it saved to your local database.',
    ),
    _FaqItem(
      question: 'What encryption does ForgeVault use?',
      answer:
          'ForgeVault uses AES-256-GCM encryption for all backup/export files. '
          'Your Master PIN is derived via PBKDF2 with a per-device salt, '
          'producing a 256-bit encryption key. The database itself is stored '
          'locally and protected by your OS\'s native storage security. Backup '
          'bundles are encrypted at rest — without your Master PIN, the file '
          'is cryptographically useless.',
    ),
    _FaqItem(
      question: 'Can my Master PIN be recovered if I forget it?',
      answer:
          'No. By design, Master PIN recovery is impossible. ForgeVault uses '
          'a zero-knowledge architecture: we never store, transmit, or escrow '
          'your PIN. It exists only on your device as a derived key. If you '
          'forget your PIN, all encrypted backups become permanently '
          'inaccessible. This is a feature, not a bug — it guarantees that '
          'no one (including us) can access your data.',
    ),
    _FaqItem(
      question: 'What is the Nuke Protocol?',
      answer:
          'The Nuke Protocol is an emergency data destruction system. When '
          'triggered, it cryptographically shreds all locally stored data '
          'including the Isar database, encryption keys, shared preferences, '
          'and cached files. This destruction is irreversible '
          '— the data cannot be recovered by any means.',
    ),
    _FaqItem(
      question: 'How does Backup & Restore work?',
      answer:
          'Export creates an AES-256-GCM encrypted bundle (.forge file) '
          'containing all your Isar data. You choose where to save it — local '
          'folder, USB drive, or cloud-synced directory (OneDrive, Dropbox, '
          'etc.). Restore decrypts the bundle with your Master PIN and merges '
          'data using a newest-wins strategy. The sync file is useless without '
          'your exact Master PIN.',
    ),
    _FaqItem(
      question:
          'How does document parsing work without sending files to the cloud?',
      answer:
          'When you upload a document (PDF, image, text file), ForgeVault uses '
          'on-device extraction to convert it to plain text. The raw file never '
          'leaves your device. Only the extracted text is sent to your AI '
          'provider for categorization into structured data fields (career, '
          'medical, financial, etc.). You review all AI-extracted data before '
          'it saves to your database.',
    ),
    _FaqItem(
      question: 'Which AI providers are supported?',
      answer:
          'ForgeVault supports 7 providers: Grok (xAI), Claude (Anthropic), '
          'Gemini (Google), OpenRouter (multi-model gateway), Groq (ultra-fast '
          'LPU inference), DeepSeek (efficient reasoning), and Mistral AI. '
          'All providers use your own API key. The Engine Room shows each '
          'provider\'s status and has direct links to their key generation '
          'dashboards.',
    ),
    _FaqItem(
      question: 'How does the AI categorize my data?',
      answer:
          'ForgeVault sends your extracted text with a strict system prompt that '
          'enforces structured JSON output into 13+ categories: Identity, '
          'Timeline, Troubles, Finances, Relationships, Health, Goals, '
          'Habits/Vices, Medical, Career, Assets, Relational Web, and Psyche '
          'Profile. The prompt includes 19 rules that prevent misrouting '
          '(e.g., jobs can\'t end up in personality traits).',
    ),
    _FaqItem(
      question: 'How does the RAG Nexus work?',
      answer:
          'The Nexus is a Retrieval-Augmented Generation (RAG) chat interface. '
          'It queries your local Isar database to build a context window, '
          'then sends that context along with your question to your configured '
          'cloud AI (via your BYOK key). The AI synthesizes an answer grounded '
          'in YOUR data — like having a personal analyst who knows everything '
          'you\'ve told ForgeVault.',
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
    _FaqItem(
      question: 'Can ForgeVault access my data without my permission?',
      answer:
          'No. ForgeVault operates on a zero-trust, zero-knowledge architecture. '
          'There are no accounts, no servers, no telemetry, and no way for anyone '
          '(including the developers) to access your data. Your database lives '
          'exclusively on your device, encrypted with keys derived from your '
          'Master PIN. Even backup files are AES-256 encrypted and useless '
          'without your PIN.',
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
