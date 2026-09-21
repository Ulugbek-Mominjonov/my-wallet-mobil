# Ishlash qoidalari (mobil repo)

> Umumiy qoidalar (til, branch, commit formati, PR) — platforma repodagi
> `my-wallet-admin/docs/CONTRIBUTING.md` 1–2, 6–7-bo'limlar bilan **bir xil**.
> Bu yerda — faqat Flutter'ga xos qoidalar.

## 1. Qatlamlar

- `packages/wallet_domain` — sof Dart: Flutter, Supabase, drift import
  qilinmaydi. Barcha biznes formulalar (BR-xxx) faqat shu yerda.
- `lib/data` — domen interfeyslarining implementatsiyasi (drift, Supabase,
  sinxron). Ekranlar `data` ni to'g'ridan-to'g'ri import qilmaydi —
  provider'lar orqali.
- `lib/features/<nom>/presentation` — ekran va vidjetlar;
  `application` — Riverpod controller'lar (Notifier). Biznes qoida
  vidjet ichida yozilmaydi.
- Bog'liqlik faqat ichkariga: `presentation → application → domain ← data`.

## 2. Riverpod

- `@riverpod` generator bilan; ro'yxat/ekran provider'lari `autoDispose`
  (ekran yopilsa — so'rov va stream to'xtaydi).
- UI faqat kerakli qismni kuzatadi (`select`) — ortiqcha qayta chizish yo'q.
- Xatolar `AsyncValue.error` orqali UI'ga; bo'sh `catch` yo'q, xato
  `AppLog` ga yoziladi.

## 3. Generatsiya qilingan kod

- `build_runner` natijalari (`*.g.dart`, `*.freezed.dart`) va l10n fayllari
  **commit qilinadi**; CI qayta generatsiya qilib farqni tekshiradi
  (`make gen` dan keyin `git diff --exit-code`).

## 4. Lokal baza (drift)

- Har sxema o'zgarishi — `schemaVersion` +1 va migratsiya qadami; sxema
  snapshot testlari (`drift_dev schema dump` / `schema steps`).
- So'rovlar: faqat kerakli ustunlar, keyset sahifalash, indeks bilan
  (`EXPLAIN QUERY PLAN` da `SEARCH`, `SCAN` emas).
- Yozuv + outbox — **bitta drift tranzaksiyasida**.

## 5. UI

- Matnlar faqat ARB orqali (`l10n/app_uz.arb` asosiy); kalit nomi:
  `<ekran>_<element>` — `payments_markPaid`.
- Ranglar/bo'shliqlar faqat dizayn tokenlaridan (`context.tokens`), kodda
  `Color(0xFF...)` yo'q.
- Summalar faqat `MoneyText` orqali (maxfiylik rejimi — BR-212).
- Har ekran: yuklanish, bo'sh, xato va oflayn holatlari; light/dark;
  matn 200% gacha kattalashtirilganda buzilmaydi.

## 6. Testlar

| Qatlam | Vosita | Joyi |
|---|---|---|
| Domen qoidalari + fixture pariteti | `test` | `packages/wallet_domain/test/` |
| drift DAO, sinxron | `flutter_test` (in-memory SQLite) | `test/data/` |
| Controller'lar | `flutter_test` + `mocktail` | `test/features/` |
| Vidjet va golden | `flutter_test` (`matchesGoldenFile`, `@Tags(['golden'])`; yangilash — `flutter test --update-goldens --tags golden`) | `test/features/**/golden/` |
| Integratsiya (lokal Supabase, host'da — `make integration`) | `flutter_test` | `integration/` |

Test nomida qoida ID si: `BR-040: 02.10 dagi Oylik 2026-09 ga tushadi`.
