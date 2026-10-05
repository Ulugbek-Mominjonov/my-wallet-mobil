import 'package:flutter/material.dart';
import 'package:my_wallet/core/design_system/tokens.dart';

/// Material 3 tema: brend rangidan sxema, semantik ranglar kengaytma sifatida.
///
/// Sayqal qoidalari (bitta joyda — ekranlar o'zidan hech narsa qo'shmaydi):
/// kartada ingichka chegara (tekis kulrang qutilar o'rniga), sarlavhalarda
/// zich harflar, mayda yorliqlar katta harf oralig'i bilan, tanlangan holat
/// aniq ko'rinadi, barmoq nishoni kamida 48 dp.
ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandSeed,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    extensions: [if (isDark) AppColors.dark else AppColors.light],
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: _textTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      // Qorong'i mavzuda kartani bir pog'ona yorug' qilamiz — fondan ajralsin.
      color: isDark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      minVerticalPadding: AppSpacing.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.secondaryContainer,
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => base.textTheme.labelMedium?.copyWith(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Barmoq uchun kamida 48 dp (a11y).
        minimumSize: const Size(64, 48),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 44)),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      // `labelStyle` berilmaydi: chip holatiga qarab matn rangini o'zi
      // tanlaydi (tanlanganda `onSecondaryContainer` — kontrast saqlanadi).
      selectedColor: scheme.secondaryContainer,
      showCheckmark: false,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: const Size(48, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? scheme.surfaceContainerHigh
          : scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      // Faol maydon aniq ko'rinsin (ayniqsa klaviatura ochilganda).
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
  );
}

/// Tipografika: sarlavha va summalarda zich harflar (katta raqam yig'iq
/// ko'rinadi), mayda yorliqlarda esa keng oraliq — ular "bo'lim nomi" bo'lib
/// o'qiladi.
TextTheme _textTheme(TextTheme base) => base.copyWith(
  displaySmall: base.displaySmall?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
  ),
  headlineMedium: base.headlineMedium?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  ),
  headlineSmall: base.headlineSmall?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  ),
  titleLarge: base.titleLarge?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  ),
  titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  labelSmall: base.labelSmall?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  ),
);
