# My Wallet — mobil ilova. `make` yoki `make help` — buyruqlar ro'yxati.
# Har bir maqsad CI'dagi qadam bilan bir xil ishlaydi (lokal = CI).

.DEFAULT_GOAL := help
.PHONY: help check lint test fmt gen run-dev

help: ## Buyruqlar ro'yxati
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

check: lint test ## Barcha tekshiruvlar (PR'dan oldin majburiy)

lint: ## Format va analiz
	@echo "lint: E04 da qo'shiladi (dart format + flutter analyze)"

test: ## Barcha testlar
	@echo "test: E04 da qo'shiladi (flutter test + qoplama)"

fmt: ## Kodni formatlash
	@echo "fmt: E04 da qo'shiladi"

gen: ## Kod generatsiyasi (build_runner, l10n)
	@echo "gen: E04 da qo'shiladi"

run-dev: ## Ilovani dev flavor bilan ishga tushirish
	@echo "run-dev: E04 da qo'shiladi"
