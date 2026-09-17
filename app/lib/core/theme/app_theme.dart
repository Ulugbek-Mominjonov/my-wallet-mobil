import 'package:flutter/material.dart';

/// Material 3 tema — Material You (dinamik rang) va qorong'i rejim bilan.
///
/// Moliyaviy ilova uchun ikkita muhim tanlov:
/// * **tabular figures** — raqamlar ustun bo'lib tizilganda "sakramaydi";
/// * semantik ranglar (musbat/manfiy) mavzudan ALOHIDA — qoldiq manfiy
///   bo'lsa qizil bo'lishi kerak, tema qanday bo'lishidan qat'i nazar.
abstract final class AppTheme {
  static const Color seed = Color(0xFF1F6F54);
  static const Color positive = Color(0xFF1F8A57);
  static const Color negative = Color(0xFFC0392B);
  static const Color warning = Color(0xFFC98A2C);
  static const Color personal = Color(0xFF6C5CE7);
  static const Color savings = Color(0xFF0B7285);

  static ThemeData light([ColorScheme? dynamicScheme]) =>
      _base(dynamicScheme ?? ColorScheme.fromSeed(seedColor: seed));

  static ThemeData dark([ColorScheme? dynamicScheme]) => _base(
        dynamicScheme ??
            ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
      );

  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark
          ? scheme.surface
          : Color.alphaBlend(scheme.primary.withValues(alpha: 0.02),
              scheme.surface),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
        space: 1,
        thickness: 1,
      ),
    );
  }
}

/// Pul raqamlari uchun uslub: bir xil kenglikdagi raqamlar.
const List<FontFeature> tabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

/// Qiymatga qarab rang: musbat — yashil, manfiy — qizil.
extension SignColor on num {
  Color get signColor =>
      this < 0 ? AppTheme.negative : AppTheme.positive;
}
