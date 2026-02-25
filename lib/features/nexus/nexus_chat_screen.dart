import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import '../../core/database/database_service.dart';
import '../../core/database/schemas/core_identity.dart';
import '../../core/database/schemas/career_ledger.dart';
import '../../core/database/schemas/medical_ledger.dart';
import '../../core/database/schemas/asset_ledger.dart';
import '../../core/database/schemas/relational_web.dart';
import '../../core/database/schemas/psyche_profile.dart';
import '../../core/database/schemas/health_profile.dart';
import '../../core/services/api_key_service.dart';
import '../../core/services/forge_api_client.dart';
import '../../core/services/local_rag_service.dart';
import '../../theme/theme.dart';
import 'mint_viewer_screen.dart';

// Regex pattern to detect DELETE tags in Nexus responses.
final _deleteTagPattern = RegExp(
  r'<DELETE>(.*?)</DELETE>',
  caseSensitive: false,
);

/// Nexus Chat Console â€” private conversational UI with BYOK LLM.
///
/// Features:
/// - Dark Forest themed chat interface
/// - Blueprint Mint chips (Resume, LLM Context, Therapist Prep)
/// - Airlock Interceptor dialog before any data egress
/// - Automatic RAG context injection from Isar vault
/// - Long-form responses open in MintViewerScreen
class NexusChatScreen extends StatefulWidget {
  final ForgeApiClient? forgeClient;

  const NexusChatScreen({super.key, this.forgeClient});

  @override
  State<NexusChatScreen> createState() => _NexusChatScreenState();
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Blueprint Definitions
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _NexusChatScreenState extends State<NexusChatScreen> {
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Blueprint Activation
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _activateBlueprint(_Blueprint bp) async {
    // ── Resume Minter: ask for target Job Description ──
    String? jobDescription;
    if (bp.name == 'resume') {
      jobDescription = await _showJobDescriptionDialog();
      // User cancelled the dialog entirely → abort
      if (jobDescription == null) return;
    }

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

    // Build the prompt — inject JD for resume minting
    String finalPrompt;
    if (bp.name == 'resume' &&
        jobDescription != null &&
        jobDescription.isNotEmpty) {
      finalPrompt =
          'You are an executive resume strategist who transforms career data '
          'into high-impact, ATS-optimized resumes. Follow this exact process:\n\n'
          'STEP 1 — STRATEGY (output inside <strategy> tags, hidden from user):\n'
          '- Identify the 5 core pain points and requirements in the JD.\n'
          '- For each pain point, map exactly which Vault data (jobs, skills, '
          'certs, clearances) solves it.\n'
          '- Identify any gaps between JD requirements and Vault data. '
          'Do NOT invent data to fill gaps.\n'
          '- Determine which past roles are irrelevant and should be '
          'minimized or omitted entirely.\n\n'
          'STEP 2 — EXECUTIVE NARRATIVE:\n'
          '- Write each bullet using: Action Verb + Specific Skill/Tool + '
          'Measurable Impact or Scope.\n'
          '- Frame existing experience to directly address JD language '
          'and priorities.\n'
          '- Front-load the most JD-relevant roles. Aggressively minimize '
          'or omit non-relevant positions.\n\n'
          'STEP 3 — OUTPUT FORMAT (CRITICAL):\n'
          '- Use ALL CAPS for section headers (e.g., PROFESSIONAL SUMMARY).\n'
          '- Use standard dashes (-) for bullet points.\n'
          '- Do NOT use any Markdown formatting. No asterisks (**), '
          'no underscores (_), no hashes (#), no bold, no italic.\n'
          '- Sections: PROFESSIONAL SUMMARY, CORE COMPETENCIES, '
          'PROFESSIONAL EXPERIENCE, CERTIFICATIONS AND CLEARANCES, '
          'EDUCATION, TECHNICAL SKILLS.\n\n'
          'RULES:\n'
          '- Use ONLY data from the Vault. Do NOT hallucinate or invent '
          'any experience, skills, or credentials.\n'
          '- Optimize keyword density for ATS scanning.\n'
          '- The Professional Summary must directly address the JD '
          'requirements in 3-4 sentences.\n\n'
          '--- TARGET JOB DESCRIPTION ---\n'
          '$jobDescription\n'
          '--- END JOB DESCRIPTION ---';
    } else {
      finalPrompt = bp.prompt;
    }

    // Add user message
    setState(() {
      _messages.add(
        _ChatMessage(
          text: '\u{1F3AB} ${bp.label}',
          isUser: true,
          isBlueprint: true,
        ),
      );
      _isProcessing = true;
    });
    _scrollToBottom();

    // Send to LLM
    await _sendToLlm(
      finalPrompt,
      isarContext: contextBlob,
      isBlueprint: true,
      blueprintTitle: bp.label,
    );
  }

  /// Show dialog for the user to paste a target Job Description.
  /// Returns the JD text (may be empty if user skips), or null if cancelled.
  Future<String?> _showJobDescriptionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.work_outline_rounded, color: Color(0xFF64B5F6)),
            const SizedBox(width: 10),
            Text(
              'Target Job Description',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste the job listing below. The resume will be '
                'tailored to match this role.',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Paste job description here...',
                  hintStyle: GoogleFonts.inter(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF64B5F6)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: Text(
              'Skip (Generic)',
              style: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Mint Resume',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Free-Form Chat
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    await _sendToLlm(text, isarContext: contextBlob);
  }

  Future<void> _sendToLlm(
    String query, {
    String isarContext = '',
    bool isBlueprint = false,
    String? blueprintTitle,
  }) async {
    try {
      // Dynamic LLM routing via ApiKeyService â€” single source of truth.
      final keyService = ApiKeyService();
      final activeProvider = await keyService.getActiveProvider();

      if (activeProvider == null) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text:
                  'Nexus requires a configured LLM provider.\n\n'
                  'Go to Engine Room â†’ API Keys to connect Grok, Claude, or Gemini.',
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
      var response = await client.askNexus(query: query, context: isarContext);

      // ── Agentic Interceptor: parse and execute <DELETE> tags ──
      final deleteMatches = _deleteTagPattern.allMatches(response).toList();
      if (deleteMatches.isNotEmpty) {
        final targets = deleteMatches.map((m) => m.group(1)!.trim()).toList();
        // Strip tags from displayed response
        response = response.replaceAll(_deleteTagPattern, '').trim();
        // Execute deletions in background
        await _executeNexusDeletions(targets);
      }

      // Strip <strategy> CoT block from resume output (hidden from user)
      response = response
          .replaceAll(
            RegExp(r'<strategy>[\s\S]*?</strategy>', caseSensitive: false),
            '',
          )
          .trim();

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
      developer.log('\x1B[31m[NEXUS] LLM Error: $e\x1B[0m', name: 'NexusChat');
      setState(() {
        _messages.add(
          _ChatMessage(text: 'Nexus Error: $e', isUser: false, isError: true),
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

  /// Execute Nexus-requested deletions across all Isar ledgers.
  Future<void> _executeNexusDeletions(List<String> targets) async {
    final db = DatabaseService.instance.db;
    int removedCount = 0;

    bool fuzzyMatch(String entry, String target) {
      final entryLower = entry.toLowerCase().trim();
      final targetLower = target.toLowerCase().trim();
      return entryLower == targetLower ||
          entryLower.contains(targetLower) ||
          targetLower.contains(entryLower);
    }

    List<String>? pruneList(List<String>? list, String target) {
      if (list == null || list.isEmpty) return list;
      final before = list.length;
      final pruned = list.where((e) => !fuzzyMatch(e, target)).toList();
      removedCount += before - pruned.length;
      return pruned;
    }

    await db.writeTxn(() async {
      for (final target in targets) {
        // Identity arrays
        final id = await db.coreIdentitys.where().findFirst();
        if (id != null) {
          id.immutableTraits = pruneList(id.immutableTraits, target);
          id.locationHistory = pruneList(id.locationHistory, target);
          id.familyLineage = pruneList(id.familyLineage, target);
          await db.coreIdentitys.put(id);
        }

        // Career
        final career = await db.careerLedgers.where().findFirst();
        if (career != null) {
          career.jobs = pruneList(career.jobs, target);
          career.degrees = pruneList(career.degrees, target);
          career.certifications = pruneList(career.certifications, target);
          career.clearances = pruneList(career.clearances, target);
          career.skills = pruneList(career.skills, target);
          career.projects = pruneList(career.projects, target);
          await db.careerLedgers.put(career);
        }

        // Medical
        final medical = await db.medicalLedgers.where().findFirst();
        if (medical != null) {
          medical.surgeries = pruneList(medical.surgeries, target);
          medical.genetics = pruneList(medical.genetics, target);
          medical.vitalBaselines = pruneList(medical.vitalBaselines, target);
          medical.visionRx = pruneList(medical.visionRx, target);
          medical.familyMedicalHistory = pruneList(
            medical.familyMedicalHistory,
            target,
          );
          medical.bloodwork = pruneList(medical.bloodwork, target);
          medical.immunizations = pruneList(medical.immunizations, target);
          medical.dentalHistory = pruneList(medical.dentalHistory, target);
          await db.medicalLedgers.put(medical);
        }

        // Assets
        final assets = await db.assetLedgers.where().findFirst();
        if (assets != null) {
          assets.realEstate = pruneList(assets.realEstate, target);
          assets.vehicles = pruneList(assets.vehicles, target);
          assets.digitalAssets = pruneList(assets.digitalAssets, target);
          assets.insurance = pruneList(assets.insurance, target);
          assets.investments = pruneList(assets.investments, target);
          assets.valuables = pruneList(assets.valuables, target);
          await db.assetLedgers.put(assets);
        }

        // Relational Web
        final rw = await db.relationalWebs.where().findFirst();
        if (rw != null) {
          rw.family = pruneList(rw.family, target);
          rw.mentors = pruneList(rw.mentors, target);
          rw.adversaries = pruneList(rw.adversaries, target);
          rw.colleagues = pruneList(rw.colleagues, target);
          rw.friends = pruneList(rw.friends, target);
          await db.relationalWebs.put(rw);
        }

        // Psyche
        final psyche = await db.psycheProfiles.where().findFirst();
        if (psyche != null) {
          psyche.beliefs = pruneList(psyche.beliefs, target);
          psyche.personality = pruneList(psyche.personality, target);
          psyche.fears = pruneList(psyche.fears, target);
          psyche.motivations = pruneList(psyche.motivations, target);
          psyche.strengths = pruneList(psyche.strengths, target);
          psyche.weaknesses = pruneList(psyche.weaknesses, target);
          await db.psycheProfiles.put(psyche);
        }

        // Health
        final hp = await db.healthProfiles.where().findFirst();
        if (hp != null) {
          hp.conditions = pruneList(hp.conditions, target);
          hp.medications = pruneList(hp.medications, target);
          hp.allergies = pruneList(hp.allergies, target);
          hp.labResults = pruneList(hp.labResults, target);
          await db.healthProfiles.put(hp);
        }
      }
    });

    if (removedCount > 0 && mounted) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                '🗑️ Nexus removed $removedCount item${removedCount > 1 ? 's' : ''} from your vault.',
            isUser: false,
          ),
        );
      });
      developer.log(
        'NEXUS DELETION: Removed $removedCount items for targets: $targets',
        name: 'NexusChat',
      );
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Airlock Interceptor Dialog
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                  '\u{1F3AB} Blueprint: $blueprintName',
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
                        '$totalItems records Â· ~$tokenEstimate tokens',
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

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Build
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
              'NEXUS',
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
          // â”€â”€ Blueprint Chips â”€â”€
          _buildBlueprintBar(),

          // â”€â”€ Chat Messages â”€â”€
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

          // â”€â”€ Input Bar â”€â”€
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
            'Your Private Nexus',
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
              'Nexus is thinking...',
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
          title: msg.blueprintTitle ?? 'Nexus Response',
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Chat Models
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                          'View Full Â· Export',
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
