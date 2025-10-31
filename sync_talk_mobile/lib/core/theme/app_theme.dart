import 'package:flutter/material.dart';

class AppTheme {
  // DEBUG: [THEME] - Primary brand colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentPurple = Color(0xFF9C27B0);

  // DEBUG: [THEME] - Semantic colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // DEBUG: [THEME] - Neutral colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // DEBUG: [THEME] - Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    print('🎨 DEBUG: [THEME] - Building light theme');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // DEBUG: [THEME] - Primary color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentCyan,
        tertiary: accentPurple,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        error: errorRed,
        brightness: Brightness.light,
      ),

      // DEBUG: [THEME] - App bar styling
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // DEBUG: [THEME] - Card styling with subtle shadow
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // DEBUG: [THEME] - Elevated button with gradient effect
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // DEBUG: [THEME] - Text button styling
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // DEBUG: [THEME] - Input field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // DEBUG: [THEME] - Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // DEBUG: [THEME] - Bottom navigation bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // DEBUG: [THEME] - Divider styling
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // DEBUG: [THEME] - Chip styling
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF5F5F5),
        deleteIconColor: textSecondary,
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // DEBUG: [THEME] - Dialog styling
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // DEBUG: [THEME] - Snackbar styling
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // DEBUG: [THEME] - Typography system
      textTheme: const TextTheme(
        // Display styles - hero text
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),

        // Headline styles - section headers
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),

        // Title styles - card headers
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),

        // Body styles - main content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.4,
        ),

        // Label styles - buttons, labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textHint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    print('🎨 DEBUG: [THEME] - Building dark theme');

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // DEBUG: [THEME] - Dark color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentCyan,
        tertiary: accentPurple,
        surface: darkSurface,
        background: darkBackground,
        error: errorRed,
        brightness: Brightness.dark,
      ),

      // DEBUG: [THEME] - Dark app bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // DEBUG: [THEME] - Dark card styling
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkCard,
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // DEBUG: [THEME] - Dark elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // DEBUG: [THEME] - Dark text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // DEBUG: [THEME] - Dark input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        hintStyle: TextStyle(
          color: darkTextSecondary.withOpacity(0.6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // DEBUG: [THEME] - Dark FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // DEBUG: [THEME] - Dark bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: darkTextSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // DEBUG: [THEME] - Dark divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),

      // DEBUG: [THEME] - Dark chip
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        deleteIconColor: darkTextSecondary,
        labelStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // DEBUG: [THEME] - Dark dialog
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // DEBUG: [THEME] - Dark snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // DEBUG: [THEME] - Dark typography
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: 0,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0,
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.1,
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Gradient backgrounds for auth screens
  static LinearGradient get authGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFF9C27B0)],
  );

  /// Glassmorphic effect decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  /// Card shadow for elevated surfaces
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

// import 'package:flutter/material.dart';
// import 'app_colors.dart';

// class AppTheme {
//   static final light = ThemeData(
//     useMaterial3: true,
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.background,
//     colorScheme: ColorScheme.light(
//       primary: AppColors.primary,
//       secondary: AppColors.secondary,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.primary,
//       foregroundColor: Colors.white,
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: const EdgeInsets.symmetric(vertical: 14),
//       ),
//     ),
//   );

//   static final dark = ThemeData.dark().copyWith(
//     colorScheme: const ColorScheme.dark(primary: AppColors.primary),
//   );
// }
