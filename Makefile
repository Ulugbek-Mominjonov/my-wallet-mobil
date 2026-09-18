# My Wallet — mobil ilova. `make` yoki `make help` — buyruqlar ro'yxati.
# Har bir maqsad CI'dagi qadam bilan bir xil ishlaydi (lokal = CI).

.DEFAULT_GOAL := help
.PHONY: help check lint test fmt gen run-dev

help: ## Buyruqlar ro'yxati
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

check: lint test ## Barcha tekshiruvlar (PR'dan oldin majburiy)

DOMAIN := packages/wallet_domain

lint: ## Format va analiz (ilova + domen paketi)
	dart format --output=none --set-exit-if-changed lib test $(DOMAIN)
	flutter analyze --fatal-infos
	cd $(DOMAIN) && dart analyze --fatal-infos

test: ## Barcha testlar (domen testlari — E12 dan boshlab)
	flutter test
	@if ls $(DOMAIN)/test/*_test.dart >/dev/null 2>&1; then cd $(DOMAIN) && dart test; fi

fmt: ## Kodni formatlash
	dart format lib test $(DOMAIN)

gen: ## Kod generatsiyasi (build_runner, l10n)
	@echo "gen: E04 da qo'shiladi"

run-dev: ## Ilovani dev flavor bilan ishga tushirish
	@echo "run-dev: E04 da qo'shiladi"
