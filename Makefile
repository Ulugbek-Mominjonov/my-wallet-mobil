# My Wallet — mobil ilova. `make` yoki `make help` — buyruqlar ro'yxati.
# Har bir maqsad CI'dagi qadam bilan bir xil ishlaydi (lokal = CI).

.DEFAULT_GOAL := help
.PHONY: help check lint test fmt gen gen-check coverage contracts-sync contracts-check run-dev

help: ## Buyruqlar ro'yxati
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

check: lint test ## Barcha tekshiruvlar (PR'dan oldin majburiy)

DOMAIN := packages/wallet_domain

lint: contracts-check ## Format, analiz (ilova + domen paketi) va shartnoma yaxlitligi
	dart format --output=none --set-exit-if-changed lib test tool $(DOMAIN)
	flutter analyze --fatal-infos
	cd $(DOMAIN) && dart analyze --fatal-infos

test: ## Barcha testlar (ilova + domen paketi)
	flutter test
	cd $(DOMAIN) && dart test

fmt: ## Kodni formatlash
	dart format lib test tool $(DOMAIN)

gen: ## Kod generatsiyasi: l10n + domen paketi (freezed)
	flutter gen-l10n
	cd $(DOMAIN) && dart run build_runner build

gen-check: gen ## Generatsiya qilingan kod commit qilinganiga mosligi (CI)
	git diff --exit-code -- lib/l10n/gen $(DOMAIN)/lib
	@test -z "$$(git status --porcelain -- $(DOMAIN)/lib)" || { echo "Commit qilinmagan generatsiya fayllari:"; git status --porcelain -- $(DOMAIN)/lib; exit 1; }

coverage: ## Testlar + qoplama chegarasi (ilova ≥ 70%, domen paketi ≥ 95%)
	flutter test --coverage
	dart run tool/check_coverage.dart coverage/lcov.info lib=70
	cd $(DOMAIN) && dart test --coverage-path=coverage/lcov.info
	cd $(DOMAIN) && dart run ../../tool/check_coverage.dart coverage/lcov.info lib=95

contracts-sync: ## Admin'dan contracts/ olish: make contracts-sync REF=<to'liq-sha|branch|papka>
	tool/sync_contracts.sh $(REF)

contracts-check: ## contracts/ qo'lda o'zgartirilmaganmi (contracts.lock)
	tool/check_contracts.sh

run-dev: ## Ilovani dev flavor bilan ishga tushirish (lokal Supabase)
	flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
