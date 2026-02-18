import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/crypto/ephemeral_key_service.dart';
import '../../core/database/database_service.dart';
import '../../core/services/api_key_service.dart';
import '../../core/services/forge_api_client.dart';
import '../../core/services/forge_service.dart';
import '../../core/services/gemini_nano_bridge.dart';
import '../../core/services/no_api_key_exception.dart';
import '../../core/services/purge_service.dart';
import '../../core/services/reality_guard_service.dart';
import '../../core/services/vacuum_service.dart';
import '../../theme/theme.dart';
import '../review/synthesis_review_screen.dart';

/// Vacuum Hub — mobile file ingestion screen with Camera & File Picker.
///
/// Features:
/// - Two massive tappable Action Buttons: "Scan Document (Camera)" and "Browse Files"
/// - Live pipeline status showing current processing phase
/// - Reality Guard error modal for AI-generated image rejection
/// - Visual distinction between Local OCR / PDF Extraction / Cloud API phases
class VacuumScreen extends StatefulWidget {
  const VacuumScreen({super.key});

  @override
  State<VacuumScreen> createState() => _VacuumScreenState();
}

/// Pipeline processing phases for UI display.
enum _PipelinePhase {
  idle,
  detecting,
  realityGuard,
  localOcr,
  pdfExtraction,
  textExtraction,
  encrypting,
  forging,
  purging,
  complete,
  error,
}

class _VacuumScreenState extends State<VacuumScreen>
    with SingleTickerProviderStateMixin {
  _PipelinePhase _phase = _PipelinePhase.idle;
  String _statusMessage = 'Ready to ingest files...';
  bool _isRealityViolation = false;
  bool _isIngesting = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Camera Scan
  // ─────────────────────────────────────────────────────────────

  Future<void> _scanDocument() async {
    if (_isIngesting) return;

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return; // User cancelled

      _startIngestion(photo.path, photo.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: VaultColors.destructive,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // File Browse
  // ─────────────────────────────────────────────────────────────

  Future<void> _browseFiles() async {
    if (_isIngesting) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'docx',
          'doc',
          'txt',
          'png',
          'jpg',
          'jpeg',
          'heic',
          'webp',
          'eml',
          'mp3',
          'wav',
          'm4a',
        ],
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;

      _startIngestion(file.path!, file.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: VaultColors.destructive,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Ingestion Pipeline
  // ─────────────────────────────────────────────────────────────

  void _startIngestion(String filePath, String fileName) {
    setState(() {
      _isIngesting = true;
      _phase = _PipelinePhase.detecting;
      _statusMessage = 'Ingesting: $fileName';
    });
    _pulseController.repeat(reverse: true);

    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: VaultColors.phosphorGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ingestion started: $fileName',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: VaultColors.surface,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Trigger VacuumService ingestion
    _runVacuumPipeline(filePath);
  }

  Future<void> _runVacuumPipeline(String filePath) async {
    try {
      final ephemeralCrypto = EphemeralKeyService();
      final database = DatabaseService.instance;
      final purgeService = PurgeService(database: database);

      final vacuum = VacuumService(
        ephemeralCrypto: ephemeralCrypto,
        purgeService: purgeService,
        database: database,
      );
      await vacuum.ingest(filePath, onPhaseChanged: _onPhaseChanged);

      // ── Forge Synthesis: send extracted text to LLM for structuring ──
      if (mounted) {
        _onPhaseChanged('Synthesizing via Forge...');
        final db = DatabaseService.instance;
        final forgeClient = ForgeApiClient(keyService: ApiKeyService());
        final forgeService = ForgeService(
          geminiNano: GeminiNanoBridge(),
          database: db,
          cloudApi: forgeClient,
        );
        final result = await forgeService.synthesizeWithReview(
          await File(filePath).readAsString().catchError((_) => ''),
        );

        _pulseController.stop();
        setState(() {
          _phase = _PipelinePhase.complete;
          _statusMessage = 'Ingestion complete ✓';
        });

        // Navigate to Diff Review Screen
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SynthesisReviewScreen(
                result: result,
                onApprove: () {
                  forgeService.commitReviewedResult(result);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Data committed to encrypted vault ✓',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      backgroundColor: VaultColors.phosphorGreen,
                    ),
                  );
                },
                onReject: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        }
      }
    } on RealityViolationException catch (e) {
      _onRealityViolation(e);
      // Show matte crimson snackbar with camera guidance
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reality Guard: Image lacks EXIF data. Android gallery '
              'may have stripped it. Use the live Camera.',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            backgroundColor: const Color(0xFF8B0000),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on NoApiKeyException {
      _pulseController.stop();
      if (mounted) {
        setState(() {
          _phase = _PipelinePhase.error;
          _statusMessage = 'No API keys configured';
        });
        _showNoApiKeyDialog();
      }
    } catch (e) {
      _pulseController.stop();
      if (mounted) {
        setState(() {
          _phase = _PipelinePhase.error;
          _statusMessage = 'Error: $e';
        });
        // Show exact error in redAccent snackbar — stop swallowing exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.inter(fontSize: 13)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      // Guarantee ingestion flag is cleared so UI never hangs.
      if (mounted) {
        setState(() => _isIngesting = false);
      }
    }
  }

  /// Show dialog prompting user to configure API keys in Engine Room.
  void _showNoApiKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VaultColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultColors.border, width: 0.5),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.vpn_key_off_rounded,
              color: Color(0xFFFFD600),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'No API Keys',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: VaultColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'The Forge requires at least one cloud LLM API key '
          '(Grok, Claude, or Gemini) to synthesize data.\n\n'
          'Go to the Engine Room to add your BYOK API key.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: VaultColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Later',
              style: GoogleFonts.inter(
                color: VaultColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Navigate to Engine Room (tab index 4)
              // Walk up to _NavigationShellState and switch tab.
              final scaffoldState = context
                  .findAncestorStateOfType<ScaffoldState>();
              if (scaffoldState != null) {
                // Fallback: just close and let user navigate manually.
              }
            },
            child: Text(
              'Go to Engine Room',
              style: GoogleFonts.inter(
                color: VaultColors.phosphorGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Map VacuumService phase strings to UI phases.
  void _onPhaseChanged(String phase) {
    setState(() {
      switch (phase) {
        case VacuumService.phaseDetecting:
          _phase = _PipelinePhase.detecting;
          _statusMessage = 'Detecting file format...';
        case VacuumService.phaseRealityGuard:
          _phase = _PipelinePhase.realityGuard;
          _statusMessage = 'Reality Guard — verifying EXIF...';
          _pulseController.repeat(reverse: true);
        case VacuumService.phaseOcr:
          _phase = _PipelinePhase.localOcr;
          _statusMessage = 'Local OCR — extracting text...';
        case VacuumService.phasePdfExtract:
          _phase = _PipelinePhase.pdfExtraction;
          _statusMessage = 'PDF Extraction — reading pages...';
        case VacuumService.phaseExtracting:
          _phase = _PipelinePhase.textExtraction;
          _statusMessage = 'Extracting raw text...';
        case VacuumService.phaseEncrypting:
          _phase = _PipelinePhase.encrypting;
          _statusMessage = 'AES-256 encryption...';
          _pulseController.stop();
      }
    });
  }

  void _onRealityViolation(RealityViolationException e) {
    _pulseController.stop();
    setState(() {
      _isRealityViolation = true;
      _phase = _PipelinePhase.error;
      _statusMessage = 'VAULT REJECTED';
      _isIngesting = false;
    });

    developer.log(
      '\x1B[31m[REALITY GUARD] ${e.message}\x1B[0m',
      name: 'VacuumScreen',
    );

    // Show error modal
    _showRealityViolationModal(e.message);
  }

  void _dismissRealityViolation() {
    setState(() {
      _isRealityViolation = false;
      _phase = _PipelinePhase.idle;
      _statusMessage = 'Ready to ingest files...';
    });
  }

  void _showRealityViolationModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0808),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8B0000), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: Color(0xFFDC143C),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'VAULT REJECTED',
              style: GoogleFonts.inter(
                color: const Color(0xFFDC143C),
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A0A0A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4A0000)),
              ),
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE8A0A0),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'VitaVault only accepts verified reality.\n'
              'No AI-generated, synthetic, or metadata-stripped images.',
              style: GoogleFonts.inter(
                color: VaultColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _dismissRealityViolation();
            },
            child: Text(
              'UNDERSTOOD',
              style: GoogleFonts.inter(
                color: const Color(0xFFDC143C),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determine the border and icon color based on state.
  Color get _zoneColor {
    if (_isRealityViolation) return const Color(0xFF8B0000);
    if (_phase == _PipelinePhase.realityGuard) return const Color(0xFFFF6B00);
    if (_phase == _PipelinePhase.localOcr ||
        _phase == _PipelinePhase.pdfExtraction) {
      return const Color(0xFF2196F3);
    }
    if (_phase == _PipelinePhase.encrypting) return VaultColors.phosphorGreen;
    if (_phase == _PipelinePhase.error) return const Color(0xFF8B0000);
    if (_phase == _PipelinePhase.complete) return VaultColors.phosphorGreen;
    return VaultColors.border;
  }

  /// Status color for each pipeline step.
  Color _getStepColor(String stepName) {
    switch (stepName) {
      case 'EXTRACT':
        if (_phase == _PipelinePhase.localOcr ||
            _phase == _PipelinePhase.pdfExtraction ||
            _phase == _PipelinePhase.textExtraction) {
          return const Color(0xFF2196F3);
        }
        if (_phase.index > _PipelinePhase.encrypting.index) {
          return VaultColors.phosphorGreen;
        }
        return VaultColors.textMuted;
      case 'FORGE':
        if (_phase == _PipelinePhase.forging) return const Color(0xFFFF9800);
        if (_phase.index > _PipelinePhase.forging.index) {
          return VaultColors.phosphorGreen;
        }
        return VaultColors.textMuted;
      case 'PURGE':
        if (_phase == _PipelinePhase.purging) return VaultColors.destructive;
        if (_phase == _PipelinePhase.complete) return VaultColors.phosphorGreen;
        return VaultColors.textMuted;
      default:
        return VaultColors.textMuted;
    }
  }

  String _getStepStatus(String stepName) {
    switch (stepName) {
      case 'EXTRACT':
        if (_phase == _PipelinePhase.realityGuard) return 'EXIF Check';
        if (_phase == _PipelinePhase.localOcr) return 'Local OCR';
        if (_phase == _PipelinePhase.pdfExtraction) return 'PDF Extract';
        if (_phase == _PipelinePhase.textExtraction) return 'Reading';
        if (_phase == _PipelinePhase.encrypting) return 'Encrypting';
        if (_phase.index > _PipelinePhase.encrypting.index) return 'Done ✓';
        return 'Waiting';
      case 'FORGE':
        if (_phase == _PipelinePhase.forging) return 'Synthesizing';
        if (_phase.index > _PipelinePhase.forging.index) return 'Done ✓';
        return 'Waiting';
      case 'PURGE':
        if (_phase == _PipelinePhase.purging) return 'Destroying';
        if (_phase == _PipelinePhase.complete) return 'Done ✓';
        return 'Waiting';
      default:
        return 'Waiting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(
          'VACUUM',
          style: GoogleFonts.inter(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Mobile Action Buttons ──
            if (!_isIngesting && !_isRealityViolation) ...[
              _buildActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'SCAN DOCUMENT',
                subtitle: 'Use camera to capture a document',
                accentColor: VaultColors.phosphorGreen,
                onTap: _scanDocument,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: Icons.folder_open_rounded,
                label: 'BROWSE FILES',
                subtitle: 'PDF • DOCX • Images • Email • Audio',
                accentColor: VaultColors.primaryLight,
                onTap: _browseFiles,
              ),
            ],

            // ── Ingesting State ──
            if (_isIngesting || _isRealityViolation)
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _zoneColor.withValues(
                            alpha: _pulseController.isAnimating
                                ? _pulseAnimation.value
                                : 0.5,
                          ),
                          width: _isRealityViolation ? 2.5 : 1.5,
                        ),
                        color: _isRealityViolation
                            ? const Color(0xFF1A0808).withValues(alpha: 0.5)
                            : VaultColors.surface.withValues(alpha: 0.3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRealityViolation
                                  ? const Color(
                                      0xFF8B0000,
                                    ).withValues(alpha: 0.3)
                                  : VaultColors.primary.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              _isRealityViolation
                                  ? Icons.shield_outlined
                                  : _phase == _PipelinePhase.complete
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cloud_upload_outlined,
                              size: 36,
                              color: _isRealityViolation
                                  ? const Color(0xFFDC143C)
                                  : _phase == _PipelinePhase.complete
                                  ? VaultColors.phosphorGreen
                                  : VaultColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isRealityViolation
                                ? 'REALITY VIOLATION'
                                : _phase == _PipelinePhase.complete
                                ? 'INGESTION COMPLETE'
                                : 'PROCESSING...',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _isRealityViolation
                                  ? const Color(0xFFDC143C)
                                  : _phase == _PipelinePhase.complete
                                  ? VaultColors.phosphorGreen
                                  : VaultColors.textSecondary,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isRealityViolation)
                            OutlinedButton.icon(
                              onPressed: _dismissRealityViolation,
                              icon: const Icon(
                                Icons.refresh,
                                size: 18,
                                color: Color(0xFFDC143C),
                              ),
                              label: Text(
                                'DISMISS',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFDC143C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // ── Pipeline Status ──
            Expanded(
              flex: _isIngesting || _isRealityViolation ? 2 : 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: VaultDecorations.metallicCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PIPELINE STATUS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: VaultColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        if (_phase != _PipelinePhase.idle &&
                            _phase != _PipelinePhase.error)
                          _ProcessingBadge(phase: _phase),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PipelineStep(
                      label: 'EXTRACT',
                      icon: Icons.document_scanner_outlined,
                      status: _getStepStatus('EXTRACT'),
                      statusColor: _getStepColor('EXTRACT'),
                    ),
                    const SizedBox(height: 12),
                    _PipelineStep(
                      label: 'FORGE',
                      icon: Icons.auto_fix_high_outlined,
                      status: _getStepStatus('FORGE'),
                      statusColor: _getStepColor('FORGE'),
                    ),
                    const SizedBox(height: 12),
                    _PipelineStep(
                      label: 'PURGE',
                      icon: Icons.delete_sweep_outlined,
                      status: _getStepStatus('PURGE'),
                      isDestructive: true,
                      statusColor: _getStepColor('PURGE'),
                    ),
                    const Spacer(),
                    // ── Status message ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: VaultColors.surfaceVariant,
                      ),
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: _isRealityViolation
                              ? const Color(0xFFDC143C)
                              : _phase == _PipelinePhase.complete
                              ? VaultColors.phosphorGreen
                              : VaultColors.textSecondary,
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: VaultColors.surface.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1.5),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VaultColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: VaultColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge showing the current processing type (Local OCR, PDF Extract, Cloud API).
class _ProcessingBadge extends StatelessWidget {
  final _PipelinePhase phase;

  const _ProcessingBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (phase) {
      case _PipelinePhase.realityGuard:
        label = 'EXIF CHECK';
        color = const Color(0xFFFF6B00);
      case _PipelinePhase.localOcr:
        label = 'LOCAL OCR';
        color = const Color(0xFF2196F3);
      case _PipelinePhase.pdfExtraction:
        label = 'PDF EXTRACT';
        color = const Color(0xFF2196F3);
      case _PipelinePhase.forging:
        label = 'CLOUD API';
        color = const Color(0xFFFF9800);
      case _PipelinePhase.complete:
        label = 'COMPLETE';
        color = VaultColors.phosphorGreen;
      default:
        label = 'PROCESSING';
        color = VaultColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final String status;
  final bool isDestructive;
  final Color? statusColor;

  const _PipelineStep({
    required this.label,
    required this.icon,
    required this.status,
    this.isDestructive = false,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        statusColor ??
        (isDestructive ? VaultColors.destructive : VaultColors.primaryLight);

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: VaultColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: status.contains('✓')
                ? VaultColors.phosphorGreen.withValues(alpha: 0.1)
                : VaultColors.surfaceVariant,
          ),
          child: Text(
            status,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              color: status.contains('✓') ? VaultColors.phosphorGreen : color,
            ),
          ),
        ),
      ],
    );
  }
}
