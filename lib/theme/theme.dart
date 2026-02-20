import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────
/// ForgeVault: Dark Forest Vault — Design System
/// ─────────────────────────────────────────────────
/// Secure, premium, impenetrable, calming.
/// Heavy mechanical animations. No bright colors.

// ── Color Palette ──

class VaultColors {
  VaultColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color cardSurface = Color(0xFF161616);

  // Primary — Forest Green
  static const Color primary = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF2D6A4F);
  static const Color primaryDark = Color(0xFF143326);

  // Highlights
  static const Color phosphorGreen = Color(0xFF39FF14);
  static const Color phosphorGreenDim = Color(0x3339FF14); // ~20% opacity
  static const Color phosphorGlow = Color(0x1A39FF14); // ~10% opacity

  // Destructive / Purge
  static const Color destructive = Color(0xFF780000);
  static const Color destructiveLight = Color(0xFF9B0000);

  // Borders & Dividers
  static const Color border = Color(0x332D6A4F); // green, 20% opacity
  static const Color borderSubtle = Color(0x1A2D6A4F);

  // Text
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);

  // Status
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFF780000);
  static const Color info = Color(0xFF1B4332);
}

// ── Metallic Card Decoration ──

class VaultDecorations {
  VaultDecorations._();

  /// Standard card with metallic gradient and thin green border.
  static BoxDecoration metallicCard({double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: VaultColors.border, width: 0.5),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A1A), Color(0xFF121212), Color(0xFF0F0F0F)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Frosted glass overlay for Cupertino-style blur panels.
  static BoxDecoration frostedGlass({double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: VaultColors.border, width: 0.5),
      color: VaultColors.surface.withValues(alpha: 0.7),
    );
  }

  /// Glowing border for active/highlighted elements.
  static BoxDecoration glowBorder({double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: VaultColors.phosphorGreenDim, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: VaultColors.phosphorGlow,
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
    );
  }
}

// ── Theme Data ──

class VaultTheme {
  VaultTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Colors ──
      colorScheme: const ColorScheme.dark(
        surface: VaultColors.background,
        primary: VaultColors.primaryLight,
        secondary: VaultColors.phosphorGreen,
        error: VaultColors.destructive,
        onPrimary: VaultColors.textPrimary,
        onSecondary: VaultColors.background,
        onSurface: VaultColors.textPrimary,
        onError: VaultColors.textPrimary,
        surfaceContainerHighest: VaultColors.surface,
      ),

      scaffoldBackgroundColor: VaultColors.background,

      // ── Typography ──
      textTheme: _buildTextTheme(),

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: VaultColors.textPrimary,
          letterSpacing: 1.2,
        ),
      ),

      // ── Navigation Bar ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: VaultColors.surface,
        indicatorColor: VaultColors.primaryDark,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: VaultColors.phosphorGreen,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: VaultColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: VaultColors.phosphorGreen,
              size: 24,
            );
          }
          return const IconThemeData(color: VaultColors.textMuted, size: 22);
        }),
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: VaultColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VaultColors.border, width: 0.5),
        ),
      ),

      // ── Inputs ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VaultColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: VaultColors.phosphorGreenDim,
            width: 1.5,
          ),
        ),
        labelStyle: GoogleFonts.inter(color: VaultColors.textSecondary),
        hintStyle: GoogleFonts.inter(color: VaultColors.textMuted),
      ),

      // ── Elevated Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultColors.primary,
          foregroundColor: VaultColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // ── Icon Theme ──
      iconTheme: const IconThemeData(
        color: VaultColors.textSecondary,
        size: 22,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: VaultColors.borderSubtle,
        thickness: 0.5,
      ),

      // ── Snack Bar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        width: 400,
        actionTextColor: VaultColors.phosphorGreen,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Bio / memoir headers
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: VaultColors.textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: VaultColors.textPrimary,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: VaultColors.textPrimary,
      ),

      // Section headings
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: VaultColors.textPrimary,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: VaultColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: VaultColors.textSecondary,
      ),

      // Body text
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: VaultColors.textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: VaultColors.textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: VaultColors.textMuted,
      ),

      // Labels & captions
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: VaultColors.textPrimary,
        letterSpacing: 0.8,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: VaultColors.textSecondary,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: VaultColors.phosphorGreen,
        letterSpacing: 0.5,
      ),
    );
  }
}
