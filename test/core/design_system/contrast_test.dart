import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/design_system/app_theme.dart';
import 'package:my_wallet/core/design_system/tokens.dart';

/// WCAG 2.x nisbiy yorqinlik.
double _luminance(Color color) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// E20-T03: summa ranglari (daromad/xarajat) va ogohlantirish matni fon
/// ustida o'qiladi — WCAG AA oddiy matn uchun ≥ 4.5.
void main() {
  const minimum = 4.5;

  for (final brightness in Brightness.values) {
    group(brightness.name, () {
      final theme = buildAppTheme(brightness);
      final colors = theme.extension<AppColors>()!;
      final scheme = theme.colorScheme;
      // Summalar sahifa foni va kartalar ustida chiqadi.
      final backgrounds = {
        'surface': scheme.surface,
        'card': scheme.surfaceContainerLow,
      };

      for (final MapEntry(key: name, value: background)
          in backgrounds.entries) {
        test('daromad va xarajat — $name ustida', () {
          expect(contrast(colors.income, background), greaterThan(minimum));
          expect(contrast(colors.expense, background), greaterThan(minimum));
        });
      }

      test('ogohlantirish fonida matn', () {
        expect(
          contrast(colors.onWarning, colors.warning),
          greaterThan(minimum),
        );
      });
    });
  }
}
