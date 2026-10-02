import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Primary Colors ──
  static const Color primaryPurple = Color(0xFFB794F4);
  static const Color deepPurple = Color(0xFF6A3092);
  static const Color accentTeal = Color(0xFF2DDCB1);
  static const Color accentTealDark = Color(0xFF1AAB87);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFF1A0D2D);
  static const Color textDark = Color(0xFF050A0F);
  static const Color textBody = Color(0xFF4B5563);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFA0A8B0);

  // ── Background Colors ──
  static const Color bgWhite = Colors.white;
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color bgSlate = Color(0xFFF8FAFC);
  static const Color bgGray100 = Color(0xFFF3F4F6);
  static const Color bgGray200 = Color(0xFFE5E7EB);
  static const Color bgDark = Color(0xFF0F1A22);
  static const Color bgDarkCard = Color(0xFF1A232A);

  // ── Status Colors ──
  static const Color statusBlue = Color(0xFF2563EB);
  static const Color statusBlueBg = Color(0xFFEFF6FF);
  static const Color statusBlueBorder = Color(0xFFDBEAFE);
  static const Color statusGreen = Color(0xFF22C55E);
  static const Color statusGreenText = Color(0xFF16A34A);
  static const Color statusTeal = Color(0xFF0D9488);
  static const Color statusTealBg = Color(0xFFF0FDFA);
  static const Color statusTealBorder = Color(0xFFCCFBF1);
  static const Color statusRed = Color(0xFFBA1A1A);
  static const Color statusYellow = Color(0xFF857F00);
  static const Color statusOrange = Color(0xFFF97316);
  static const Color statusOrangeBg = Color(0xFFFFF7ED);

  // ── Gradients ──
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment(0.00, 0.50),
    end: Alignment(1.00, 0.50),
    colors: [Color(0xFFA161D2), Color(0xFF64417F), Color(0xFF27202C)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment(0.00, 0.00),
    end: Alignment(1.00, 1.00),
    colors: [Color(0xFF2DDCB1), Color(0xFF1AAB87)],
  );

  // ── Shadows ──
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];

  // ── Border Radius ──
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // ── Spacing ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // ── Text Styles ──
  static TextStyle get headingXl => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: textDark,
    height: 1.10,
    letterSpacing: -0.50,
  );

  static TextStyle get headingLg => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get headingMd => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.56,
  );

  static TextStyle get titleMd => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.50,
  );

  static TextStyle get bodyLg => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textBody,
    height: 1.63,
  );

  static TextStyle get bodyMd => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textBody,
    height: 1.43,
  );

  static TextStyle get bodySm => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
    height: 1.33,
  );

  static TextStyle get captionBold => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: textMuted,
    height: 1.33,
  );

  static TextStyle get labelSm => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: textMuted,
    height: 1.50,
  );

  static TextStyle get timestamp => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textHint,
    height: 1.50,
  );

  static TextStyle get navLabel => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF53595D),
    height: 1.50,
  );

  // ── Card Decoration ──
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double radius = radiusXl,
    Color bgColor = bgWhite,
  }) =>
      BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? bgGray100,
          width: 1,
        ),
      );

  // ── Theme Data ──
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      surface: const Color(0xFFF8F9FA),
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryPurple,
      surface: const Color(0xFF2D3748),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}