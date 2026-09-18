import 'package:flutter/material.dart';

/// Brend rangi — admin panel bilan bir xil (indigo, oklch 0.51 0.19 268).
const brandSeed = Color(0xFF4F46E5);

/// Bo'shliqlar (4 pt setka).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Burchak radiuslari.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Pul ma'nosidagi semantik ranglar — Material rang sxemasiga qo'shimcha.
/// Daromad yashil, xarajat qizil, ogohlantirish sariq (admin tokenlari bilan
/// bir xil ma'no).
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const new({
    required this.income,
    required this.expense,
    required this.warning,
    required this.onWarning,
  });

  static const light = AppColors(
    income: Color(0xFF15803D),
    expense: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    onWarning: Color(0xFF3B2A06),
  );

  static const dark = AppColors(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF3B2A06),
  );

  final Color income;
  final Color expense;
  final Color warning;
  final Color onWarning;

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? onWarning,
  }) => AppColors(
    income: income ?? this.income,
    expense: expense ?? this.expense,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}

/// `context.appColors.income` kabi qisqa murojaat.
extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
