import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/reality_guard_service.dart';
import '../../core/services/vacuum_service.dart';
import '../../theme/theme.dart';

/// Vacuum Hub — file ingestion screen with Reality Guard protection.
///
/// Features:
/// - Animated dashed-border drop zone (pulses green on drag, crimson on reject)
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
  String _statusMessage = 'Waiting for files...';
  bool _isRealityViolation = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

  /// Map VacuumService phase strings to UI phases.
  // ignore: unused_element
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

  // ignore: unused_element
  void _onRealityViolation(RealityViolationException e) {
    _pulseController.stop();
    setState(() {
      _isRealityViolation = true;
      _phase = _PipelinePhase.error;
      _statusMessage = 'VAULT REJECTED';
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
      _statusMessage = 'Waiting for files...';
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

  /// Determine the drop zone border and icon color based on state.
  Color get _dropZoneColor {
    if (_isRealityViolation) return const Color(0xFF8B0000); // Matte Crimson
    if (_phase == _PipelinePhase.realityGuard) return const Color(0xFFFF6B00);
    if (_phase == _PipelinePhase.localOcr ||
        _phase == _PipelinePhase.pdfExtraction) {
      return const Color(0xFF2196F3);
    }
    if (_phase == _PipelinePhase.encrypting) return VaultColors.phosphorGreen;
    if (_phase == _PipelinePhase.error) return const Color(0xFF8B0000);
    return VaultColors.border;
  }

  /// Status color for each pipeline step.
  Color _getStepColor(String stepName) {
    switch (stepName) {
      case 'EXTRACT':
        if (_phase == _PipelinePhase.localOcr ||
            _phase == _PipelinePhase.pdfExtraction ||
            _phase == _PipelinePhase.textExtraction) {
          return const Color(0xFF2196F3); // Blue = local processing
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
            // ── Drop Zone ──
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
                        color: _dropZoneColor.withValues(
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
                                ? const Color(0xFF8B0000).withValues(alpha: 0.3)
                                : VaultColors.primary.withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            _isRealityViolation
                                ? Icons.shield_outlined
                                : Icons.cloud_upload_outlined,
                            size: 36,
                            color: _isRealityViolation
                                ? const Color(0xFFDC143C)
                                : VaultColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isRealityViolation
                              ? 'REALITY VIOLATION'
                              : 'DROP FILES HERE',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _isRealityViolation
                                ? const Color(0xFFDC143C)
                                : VaultColors.textSecondary,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRealityViolation
                              ? 'Image rejected by Reality Guard'
                              : 'PDF • DOCX • Images • Email • Audio',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _isRealityViolation
                                ? const Color(0xFFE8A0A0)
                                : VaultColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isRealityViolation)
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: const Text('BROWSE FILES'),
                          ),
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
                              side: const BorderSide(color: Color(0xFF8B0000)),
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
              flex: 2,
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
