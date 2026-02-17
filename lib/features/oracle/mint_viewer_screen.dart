import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/export_mint_service.dart';
import '../../theme/theme.dart';

/// Mint Viewer — rich Markdown rendering with export actions.
///
/// Displays the LLM's long-form generated document (resume, clinical
/// summary, LLM context file) with persistent action buttons:
/// Copy to Clipboard · Export as .MD · Mint as PDF
class MintViewerScreen extends StatelessWidget {
  final String content;
  final String title;

  const MintViewerScreen({
    super.key,
    required this.content,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: VaultColors.textMuted,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              color: VaultColors.phosphorGreen,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: VaultColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Markdown Content ──
          Expanded(
            child: Markdown(
              data: content,
              selectable: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              styleSheet: MarkdownStyleSheet(
                h1: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: VaultColors.textPrimary,
                  height: 1.3,
                ),
                h2: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: VaultColors.textPrimary,
                  height: 1.4,
                ),
                h3: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VaultColors.textSecondary,
                  height: 1.4,
                ),
                p: GoogleFonts.inter(
                  fontSize: 14,
                  color: VaultColors.textSecondary,
                  height: 1.7,
                ),
                listBullet: GoogleFonts.inter(
                  fontSize: 14,
                  color: VaultColors.primaryLight,
                ),
                code: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  backgroundColor: VaultColors.surfaceVariant,
                  color: VaultColors.phosphorGreen,
                ),
                codeblockDecoration: BoxDecoration(
                  color: VaultColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: VaultColors.border, width: 0.5),
                ),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: VaultColors.primary, width: 3),
                  ),
                ),
                blockquotePadding: const EdgeInsets.only(left: 12),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: VaultColors.border, width: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // ── Export Actions ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: VaultColors.surface,
              border: Border(
                top: BorderSide(color: VaultColors.border, width: 0.5),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _ExportButton(
                    icon: Icons.copy_rounded,
                    label: 'COPY',
                    onTap: () => _copyToClipboard(context),
                  ),
                  const SizedBox(width: 10),
                  _ExportButton(
                    icon: Icons.description_outlined,
                    label: 'EXPORT .MD',
                    onTap: () => _exportMarkdown(context),
                  ),
                  const SizedBox(width: 10),
                  _ExportButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'MINT PDF',
                    isPrimary: true,
                    onTap: () => _mintPdf(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    ExportMintService.copyToClipboard(content);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: VaultColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportMarkdown(BuildContext context) async {
    try {
      final path = await ExportMintService.exportAsMarkdown(
        content: content,
        filename: title,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved: $path',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            backgroundColor: VaultColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: VaultColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _mintPdf(BuildContext context) async {
    try {
      final path = await ExportMintService.mintAsPdf(
        content: content,
        title: title,
      );
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF minted: $path',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            backgroundColor: VaultColors.phosphorGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF mint failed: $e'),
            backgroundColor: VaultColors.destructive,
          ),
        );
      }
    }
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isPrimary ? VaultColors.primary : VaultColors.surfaceVariant,
            border: isPrimary
                ? null
                : Border.all(color: VaultColors.border, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? VaultColors.phosphorGreen
                    : VaultColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isPrimary
                      ? VaultColors.phosphorGreen
                      : VaultColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
