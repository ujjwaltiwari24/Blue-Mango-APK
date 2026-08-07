import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =======================================================
/// BlueMango Design System
/// =======================================================

class AppColors {
  AppColors._();

  // ===================================================
  // Brand Colors
  // ===================================================

  static const Color primaryBlue = Color(0xFF046CC8);
  static const Color secondaryBlue = Color(0xFF0353A4);
  static const Color accentBlue = Color(0xFF023E7D);
  static const Color darkBlue = Color(0xFF002855);

  // ===================================================
  // Neutral Colors
  // ===================================================

  static const Color slate = Color(0xFF33415C);
  static const Color secondarySlate = Color(0xFF5C677D);
  static const Color muted = Color(0xFF7D8597);
  static const Color light = Color(0xFF979DAC);

  // ===================================================
  // Background
  // ===================================================

  static const Color primaryBackground = Color(0xFF09090B);
  static const Color cardBackground = Color(0xFF111114);
  static const Color secondaryCard = Color(0xFF18181B);

  static const Color background = primaryBackground;
  static const Color scaffold = primaryBackground;
  static const Color surface = secondaryCard;
  static const Color card = cardBackground;

  // ===================================================
  // Divider & Border
  // ===================================================

  static const Color divider = Color(0xFF232326);
  static const Color border = Color(0xFF33415C);

  // ===================================================
  // Text
  // ===================================================

  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textHint = muted;
  static const Color textMuted = muted;

  // ===================================================
  // Status
  // ===================================================

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ===================================================
  // Social
  // ===================================================

  static const Color like = Color(0xFFFF4D6D);
  static const Color verified = Color(0xFF2196F3);
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF6B7280);

  // ===================================================
  // Buttons
  // ===================================================

  static const Color buttonPrimary = primaryBlue;
  static const Color buttonSecondary = secondaryBlue;
  static const Color buttonDisabled = Color(0xFF3F3F46);

  // ===================================================
  // Inputs
  // ===================================================

  static const Color inputFill = Color(0xFF1A1A1D);
  static const Color inputBorder = border;
  static const Color inputFocused = primaryBlue;

  // ===================================================
  // Common
  // ===================================================

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // ===================================================
  // Gradients
  // ===================================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      accentBlue,
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      secondaryBlue,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cardBackground,
      secondaryCard,
    ],
  );

  // ===================================================
  // Shadows
  // ===================================================

  static List<BoxShadow> glow({
    Color color = primaryBlue,
    double opacity = .35,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 28,
        spreadRadius: -6,
        offset: const Offset(0, 10),
      ),
    ];
  }

  // ===================================================
  // Anonymous Avatar Gradients
  // ===================================================

  static const List<List<Color>> identityGradients = [
    [Color(0xFF046CC8), Color(0xFF023E7D)],
    [Color(0xFF0353A4), Color(0xFF002855)],
    [Color(0xFF5C677D), Color(0xFF33415C)],
    [Color(0xFF046CC8), Color(0xFF5C677D)],
    [Color(0xFF0353A4), Color(0xFF046CC8)],
  ];
}

class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 36;
  static const double pill = 100;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double xxl = 40;
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final base =
    GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor:
      AppColors.background,

      splashFactory: NoSplash.splashFactory,

      highlightColor: Colors.transparent,

      dividerColor: AppColors.divider,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryBlue,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),

      cardColor: AppColors.cardBackground,

      textTheme: base.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineMedium:
        GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        titleLarge:
        GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium:
        GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge:
        GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.45,
        ),
        bodyMedium:
        GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelLarge:
        GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        labelSmall:
        GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}