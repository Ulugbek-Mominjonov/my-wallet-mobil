import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/format/month_format.dart';
import 'package:my_wallet/core/l10n/locale_resolution.dart';
import 'package:my_wallet/l10n/gen/app_localizations.dart';

void main() {
  group('oy sarlavhasi (admin bilan bir xil)', () {
    test('uz / ru / en', () {
      expect(
        formatMonthTitle(
          lookupAppL10n(const Locale('uz')),
          year: 2026,
          month: 9,
        ),
        'Sentabr 2026',
      );
      expect(
        formatMonthTitle(
          lookupAppL10n(const Locale('ru')),
          year: 2026,
          month: 9,
        ),
        'Сентябрь 2026',
      );
      expect(
        formatMonthTitle(
          lookupAppL10n(const Locale('en')),
          year: 2026,
          month: 1,
        ),
        'January 2026',
      );
    });

    test("noto'g'ri oy raqami xato beradi", () {
      expect(
        () => formatMonthTitle(
          lookupAppL10n(const Locale('uz')),
          year: 2026,
          month: 13,
        ),
        throwsRangeError,
      );
    });
  });

  group('til tanlash', () {
    test("qo'llab-quvvatlanadigan qurilma tili tanlanadi", () {
      expect(
        resolveAppLocale(const Locale('ru', 'RU'), appSupportedLocales),
        const Locale('ru'),
      );
    });

    test("noma'lum til — o'zbekcha (ADR-15)", () {
      expect(
        resolveAppLocale(const Locale('de'), appSupportedLocales),
        const Locale('uz'),
      );
      expect(resolveAppLocale(null, appSupportedLocales), const Locale('uz'));
    });
  });
}
