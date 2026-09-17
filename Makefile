# Oylik byudjet — mobil ilova.
#
# Flutter SDK yo'li muhitga bog'liq bo'lmasligi uchun:
#   make test FLUTTER=/path/to/flutter/bin/flutter
FLUTTER ?= flutter
DART ?= dart

.PHONY: help get analyze test fixtures coverage clean

help:
	@echo "get       — bog'liqliklarni o'rnatadi"
	@echo "analyze   — domain + data_firebase + app analizi"
	@echo "test      — barcha testlar"
	@echo "fixtures  — umumiy fixture'larni qayta yaratadi (admin repo uchun)"
	@echo "coverage  — domen qoplamasi (calc/ ≥95% talab qilinadi)"

get:
	cd packages/domain && $(DART) pub get
	cd packages/data_firebase && $(FLUTTER) pub get
	cd app && $(FLUTTER) pub get

analyze:
	cd packages/domain && $(DART) analyze --fatal-infos
	cd packages/data_firebase && $(FLUTTER) analyze
	cd app && $(FLUTTER) analyze

test:
	cd packages/domain && $(DART) test
	cd packages/data_firebase && $(FLUTTER) test
	cd app && $(FLUTTER) test

# Fixture'lar `oylik-byudjet-admin` repodagi TS porti bilan shartnoma —
# o'zgarsa u yerda ham sinxronlash kerak.
fixtures:
	cd packages/domain && $(DART) run tool/generate_fixtures.dart
	@echo "→ Endi admin repoda: make sync-fixtures"

coverage:
	cd packages/domain && $(DART) test --coverage=.coverage \
	  && $(DART) pub global run coverage:format_coverage --lcov \
	     --in=.coverage --out=.coverage/lcov.info --report-on=lib \
	     --packages=.dart_tool/package_config.json \
	  && python3 ../../tool/check_coverage.py .coverage/lcov.info

clean:
	rm -rf packages/domain/.dart_tool packages/domain/.coverage
	rm -rf packages/data_firebase/.dart_tool app/.dart_tool app/build
