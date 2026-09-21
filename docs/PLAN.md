# My Wallet mobil — vazifalar

> **Yo'l xaritasi, ish tartibi, DoD va ochiq savollar** — master rejada:
> `my-wallet-admin/docs/PLAN.md` (1–4-bo'limlar). Bu faylda faqat mobil
> repodagi vazifalar; ID'lar master bilan umumiy va yagona.
>
> Asoslar: [`ARXITEKTURA.md`](ARXITEKTURA.md) · `contracts/BIZNES-QOIDALAR.md`
> (BR-xxx) · [`DEPLOY.md`](DEPLOY.md).

**Mobil DoD (umumiyga qo'shimcha):**
- [ ] `dart format` / `flutter analyze --fatal-infos` toza, testlar yashil (`make check`).
- [ ] `wallet_domain/rules` qoplamasi ≥ 95%, umumiy ≥ 70%.
- [ ] Ekran: light/dark, uz/ru/en, matn 200% da buzilmaydi, oflayn holatda ishlaydi.
- [ ] Yangi so'rov lokal indeks bilan (`EXPLAIN QUERY PLAN` — `SCAN` emas `SEARCH`).

---

### E04 · Mobil skelet + CI `[mobile]`

> **Maqsad:** flavor'li bo'sh ilova, domen paketi, dizayn tizimi asosi, CI
> yashil. **DoD:** `flutter run --flavor dev` ishlaydi; CI PR'da yashil.

- [x] **E04-T01** Flutter loyiha (`flutter create --platforms=android`,
  `uz.mywallet.app`, "My Wallet"; iOS — Q4 bo'yicha keyinroq), pub
  workspace + `packages/wallet_domain` (sof Dart), `very_good_analysis`,
  `Makefile` (`check`, `gen`, `test`, `fmt`, `run-dev`), Dependabot'ga `pub` yozuvi.
- [x] **E04-T02** Flavor'lar `dev` / `staging` / `prod`: Android
  `productFlavors` (`applicationIdSuffix` `.dev` / `.stg`, ilova nomi
  qo'shimchasi — AGP 9 `resValues`), `main_<flavor>.dart`,
  `--dart-define-from-file=env/<flavor>.json` (`env/*.example.json` repoda,
  haqiqiylari `.gitignore` da), `AppConfig` noto'g'ri env faylni rad etadi.
  Flavor rangli ikonlari → E20-T01 (brend ikoni bilan birga).
- [x] **E04-T03** `bootstrap.dart`: `FlutterError.onError` +
  `PlatformDispatcher.onError` (zamonaviy tavsiya — `runZonedGuarded` kerak
  emas), `AppLog` (debug — konsol, release — ulanadigan `ErrorReporter`;
  Crashlytics E20 da), Riverpod `ProviderScope` + `AppProviderObserver`,
  `appConfigProvider`. Kechiktirilgan init — Firebase qo'shilganda (E19).
- [x] **E04-T04** Dizayn tizimi asosi: tokenlar (`AppColors` ThemeExtension —
  income/expense/warning light/dark, `AppSpacing`, `AppRadii`), Material 3
  tema (admin bilan bir xil indigo brend), `formatMoney` (admin bilan bir xil
  kutilmalar — parite), `MoneyText` (tabular raqamlar, maxfiylik rejimi
  BR-212), `AppCard`, `EmptyState`, `Skeleton` (reduce-motion'ni hurmat
  qiladi), dev katalog ekrani. Alohida `AppButton` yo'q — Material tugmalari
  tema orqali (keraksiz o'ram emas).
- [x] **E04-T05** l10n: `gen-l10n`, `l10n/app_uz.arb` (asosiy), `app_ru.arb`,
  `app_en.arb`; pul/sana formatlari (`1 234 567 so'm`, `Sentabr 2026`) +
  testlar.
- [x] **E04-T06** go_router karkasi: `StatefulShellRoute` (4 tab holatini
  saqlaydi) + o'rtada chuqurchali "＋" (BottomAppBar notch), `/add` sahifasi
  (vidjet/tez amallar deep-link'i uchun), 404 ekrani, dev katalog (faqat dev);
  auth/onboarding redirect'lari → E14. Navigatsiya testlari (5 ta).
- [x] **E04-T07** CI `ci.yml`: `dart` job (Flutter 3.47.4 pinned + kesh →
  `make gen-check` → `make lint` → `make coverage`: umumiy ≥ 70%, hozir
  88%) va `android` job (dev APK build — Gradle/manifest xatolari). Action'lar
  SHA bilan pin. `tool/check_coverage.dart` (prefiks bo'yicha chegara,
  generatsiya qilingan kod hisobga olinmaydi).
- [x] **E04-T08** `contracts/` + `contracts.lock` (admin commit + sha256) +
  `tool/sync_contracts.sh <to'liq-sha|branch|papka>` + `tool/check_contracts.sh`
  (`make lint` ichida — qo'lda o'zgartirilgan nusxa CI'da yiqiladi; buzilish
  testi o'tkazildi).

### E12 · Domen paketi + fixtures pariteti `[mobile]`

> **Qoidalar:** BR-001..005, 040..046, 060, 071..076, 090..103, 112..114,
> 121, 130, 160. **DoD:** barcha `contracts/fixtures` holatlari Dart'da
> yashil; qoplama ≥ 95%.

- [x] **E12-T01** Value object'lar: `Money` (int eng kichik birlik + valyuta,
  `+ − *`, `roundTo` — Postgres `round` bilan bir xil, noldan uzoqqa;
  `parse` — `1 200 000`, `1,200,000`, `1 200 000,50`), `Currency`
  (exponent), `MonthKey` (`shift`, `daysInMonth`, `dayOf` qisish),
  `LocalDate` (kun aniqligi, BR-002). Domen qoplamasi `make coverage` da
  (≥ 95%, hozir 98.9%).
- [x] **E12-T02** Entity'lar (freezed 4, Dart 3.13 konstruktor sintaksisi):
  Household (+ `PersonalFundRule`, foiz — bazis punktda), Member, Account,
  Category, RecurringRule, PlannedItem, Transaction, Debt, Goal,
  CategoryLimit, QuickAction, Tag; enum'lar server `wire` qiymatlari bilan;
  `Failure` sealed klasslari (`ValidationFailure(field, code)`,
  `ConflictFailure`, `MonthClosedWarning`). `make gen` domen paketini ham
  generatsiya qiladi, `gen-check` — commit qilinmagan fayllarni ham ushlaydi.
- [x] **E12-T03** Qoidalar: `attributeBudgetMonth` (BR-040..046 — serverdagi
  tartibda: qo'lda → reja oyi → daromad siljishi → sana oyi),
  `PlannedStatus` (BR-071, `partial`/`skipped` bilan), `personalAllocation`
  (BR-060 — bir marta yaxlitlash, foiz bazis punktda, birlik —
  `Currency.allocationUnit`), `ReminderBuckets` (BR-160, offline eslatma
  BR-168 uchun ham).
- [x] **E12-T04** Qoidalar: `MonthFacts` + `MonthSummary` (BR-090/091),
  `OverallTotals` (BR-092 + invariant), `MonthForecast` (BR-093, kutilayotgan
  daromad rejalari bilan), `safeToSpendPerDay` (BR-094), `savingsTable` /
  `MonthSavings` (BR-100..102), `DebtProgress` / `DebtTotals` (BR-112..114),
  `GoalProgress` (BR-121, BR-122), `limitStatus` (BR-130). Hammasi serverdagi
  SQL bilan bir xil yaxlitlash (butun sonlarda, `round` — noldan uzoqqa);
  domen qoplamasi 100%.
- [x] **E12-T05** Fixture yuklovchi (`test/support/fixture_ledger.dart` —
  admin'dagi `load_fixture.sql` + triggerlar bilan bir xil yozuv yo'li:
  standart to'plam, tegishli oy, "O'zim uchun", rejaning qarzi, to'langan
  summa, fond rejasi, `settle`) va parametrlangan testlar: har
  `contracts/fixtures/*.json` holati → 6 hisobot (`report_month`, `_year`,
  `_savings`, `_personal_fund`, `_debts`, `_goals`) → `run.mjs` bilan bir xil
  solishtiruv; test nomida BR ID. **51/51 holat mos** (40 tasi eski tizimdan);
  ataylab 1 tiyin xato — aniq ushlandi. Amal tasnifi (`BudgetLine`,
  `monthFactsOf`, BR-022/061..063/090) domen qoidasi sifatida — E13 SQL'i
  uchun ham namuna.
- [x] **E12-T06** Repository interfeyslari (`HouseholdRepository`,
  `AccountRepository`, `CategoryRepository`, `PlannedItemRepository`,
  `TransactionRepository`, `QuickActionRepository`, `Transactor` — yozuv +
  outbox + reja bitta lokal tranzaksiyada, `IdGenerator`, `Clock`) va
  use-case'lar: `AddTransaction`, `EditTransaction` (BR-043), `DeleteTransaction`
  (undo uchun snapshot) + `UndoDeleteTransaction`, `AddTransfer`,
  `PayPlanned` (BR-073), `SkipPlanned`, `QuickAdd` (BR-141),
  `AddPersonalSpend` (BR-062). Natija — `Result` (`Ok`/`Err(Failure)`),
  kodlar server bilan bir xil; yopilgan oy (BR-055) — tasdiq/taqiq; reja
  to'lovi lokal taxmini — `settlePlan` (fixture ledger ham shuni ishlatadi).

### E13 · Lokal baza va sinxron dvigatel `[mobile]`

> **Qoidalar:** BR-006, BR-007, ARX 5–6. Bog'liqlik: E10 (admin).
> **DoD:** aviarejimda yozuv → darhol ekranda → tarmoq kelganda serverda;
> to'qnashuv va rad etish UI'da; lokal Supabase bilan integratsiya testlari.

- [x] **E13-T01** drift 2.35 sxemasi: 14 sinxron jadval nusxasi (ustunlar
  serverdagi bilan bir xil — pull qatori snake_case JSON bilan to'g'ridan-
  to'g'ri; pul — butun son, sana/oy — ISO matn, enum — server qiymati; lokal
  FK yo'q — pull tartibi) + `outbox` (yuborilmagan mutatsiya — qatorga bitta,
  qisman unique indeks), `sync_state`, `sync_issues`; indekslar
  `(household_id, budget_month)`, `(household_id, occurred_on)`,
  `(planned_item_id)`, `(debt_id)` — oy so'rovi `SEARCH`. Migratsiya:
  `schemaVersion` + `drift_schemas/` snapshot (`make gen` → `make-migrations`,
  `gen-check` eskirganini ushlaydi).
- [x] **E13-T02** `LedgerDao`: reaktiv ro'yxat (keyset, 50 tadan, indeks —
  saralash ham), `monthFacts` — serverdagi `budget_lines` + `month_facts`
  SQL'da (bitta GROUP BY, domen `MonthFacts` qaytaradi), hisob qoldiqlari,
  qarz faolligi (to'lovlar, kutilayotgan rejalar), shu oy qarz to'lovlari,
  joy nomi avto-to'ldirish (oxirgi kategoriya/hisob — BR-056). Entity ↔ qator
  mapperlari (round-trip testi). Parite: 51 fixture holati — SQL = domen
  (oylar, qoldiqlar, qarzlar); fixture'larda yo'q holatlar (fonddan qaytish,
  byudjet hisoblari orasidagi o'tkazma) — alohida test; mutatsiya testi bilan
  tekshirilgan. `FixtureLedger` domen paketining `testing` kutubxonasiga
  ko'chdi (ilova testlari ham ishlatadi).
- [x] **E13-T03** `RemoteApi` (Supabase RPC, `RpcTransport` orqali —
  testda soxta): `app_bootstrap`, `sync_pull`, `sync_push`, `open_month`,
  `open_month_preview`, `onboarding_apply`, `accept_invite`,
  `telegram_link_token`, `register_device`; javoblar qat'iy o'qiladi
  (shartnoma buzilsa — log + `invalid_response`); xatolar → `Failure`:
  `P0001` → `RejectedFailure(biznes kod)`, `PGRST30x`/auth →
  `UnauthorizedFailure`, tarmoq/timeout (20 s) → `OfflineFailure`,
  kutilmagan xato — yutilmaydi. Haqiqiy `app_bootstrap` javobi bilan test.
- [x] **E13-T04** Repository'lar (domen interfeyslari — drift): yozish =
  lokal qator + outbox bitta tranzaksiyada (`DriftTransactor`, `save` ham
  atomar); bir qatorning yuborilmagan o'zgarishlari birlashtiriladi (bitta
  mutatsiya, birinchi `base_version`); yuborilayotganiga (`sending`)
  tegilmaydi — javob yo'qolsa keyingi o'zgarish yo'qolmasin; serverga
  yetmagan yangi qator o'chirilsa — mutatsiya bekor. Push ma'lumoti — to'liq
  qator (snake_case, server maydonlarisiz; server ustun huquqlari bilan
  kesadi). `UuidV7Ids`, `TzClock` (BR-002: bugun — byudjet vaqt zonasida).
  Domen use-case'lari haqiqiy lokal bazada sinaldi.
- [x] **E13-T05** `SyncEngine`: push (≤ 100, har qatordan bitta mutatsiya,
  navbat bo'shaguncha; `ok` — kanonik qator yoki keyingi lokal o'zgarishga
  yangi versiya; `conflict` — server qatori + `sync_issues`; `rejected` —
  `base_row` ga qaytarish yoki yangi qatorni o'chirish + muammo; tarmoq
  xatosida o'sha mutatsiyalar o'sha ID bilan qayta; javoblar soni mos
  kelmasa — to'xtaydi), pull (sahifalab, yuborilmagan o'zgarishli qatorlar
  himoyada, noma'lum jadval — o'tkaziladi, kursor bir tranzaksiyada),
  `resync_required` (byudjet tozalanib qayta yuklanadi), bir vaqtda bitta
  sikl (ishlayotganda kelgan chaqiruv — keyin yana bir marta).
  `SyncScheduler`: start, yozuv debounce 1 s, tarmoq (darhol, hisob nolga),
  resume, pull-to-refresh; oflaynda 1→2→4…300 s. Platforma ulanishi — T06.
- [x] **E13-T06** Fon sinxron: Android WorkManager (6 soat, tarmoq sharti;
  sessiya yo'q — o'tkaziladi, tarmoq xatosi — qayta urinish; yadrosi
  `runBackgroundSync` — testlangan). Provider'lar: baza, RPC, qurilma ID
  (`app_settings`), joriy byudjet (E14 o'rnatadi), dvigatel, rejalashtiruvchi
  (tarmoq qaytishi — `connectivity_plus`, resume — `AppLifecycleListener`),
  `SyncStatus` (navbat, muammolar, kursor, jonli jarayon). `SyncStatusBadge`
  (✓ · ↻ · navbat · 📴 · ⚠️ N · qayta kirish) + "Sinxron holati" ekrani
  (`/sync`): holat, oxirgi sinxron, "Hozir sinxronlash", muammolar —
  "Mening versiyam" (to'qnashuvda) / "Tushunarli", "To'liq qayta yuklash"
  (tasdiq bilan). Supabase `bootstrap` da ishga tushadi. Qobiqqa joylash —
  E14-T04.
- [x] **E13-T07** Integratsiya testlari (`integration/sync/` — host'da,
  emulyatorsiz: `integration_test/` qurilma talab qiladi): admin repoda
  `contracts.lock` dagi commit → `supabase start` → 2 "qurilma" (alohida
  lokal baza + klient, bitta foydalanuvchi) simulyatsiyasi: offline yozuv →
  push (server maydonlari bilan); bir qatorni ikki qurilmada tahrirlash →
  conflict + muammo; o'chirilgan hisobga yozuv → rad etish + qaytarish;
  o'chirish → tombstone, qaytarish → ikkinchi qurilmada ham. `make
  integration` (kalitlar `supabase status` dan yoki `SUPABASE_*` env).
  CI: `integration.yml` (PR, main, har kecha). Topilgan xato: drift
  data-class upsert NULL maydonni yozmaydi (tiklangan tombstone qaytmasdi) —
  pull `toCompanion(false)` bilan; regressiya testi bor.

### E14 · Auth, onboarding, ilova qobig'i `[mobile]`

> **Qoidalar:** BR-010..012, BR-031, BR-060, BR-080, BR-211, BR-214.
> **DoD:** yangi foydalanuvchi 2 daqiqada sozlab, joriy oy ochilgan holda
> dashboard'ni ko'radi.

- [x] **E14-T01** Kirish: Google (native, google_sign_in 7 → `signInWithIdToken`;
  har kirishda yangi nonce — Google'ga `sha256`, Supabase'ga xomi) va email
  kodi (6 xona, admin `otp_length`; qayta yuborish 30 s — `max_frequency`).
  Xatolar `Result` bilan: tarmoq/timeout → oflayn, GoTrue kodi → rad etish,
  bekor qilish — xato emas; matnlar uz/ru/en. Sessiya
  `flutter_secure_storage` da (`SecureSessionStorage`, ilova va fon sinxroni
  bitta `initSupabase`). Router: kirilmagan — faqat `/sign-in`, sessiya
  eskirsa avtomatik qaytadi; byudjet tanlovi ham bekor bo'ladi. Chiqish:
  tasdiq (yuborilmagan o'zgarishlar soni bilan) → sessiya + lokal
  ma'lumot tozalanadi (qurilma ID si qoladi); tugmasi qobiqda — T04.
  Android: INTERNET ruxsati (release'da yo'q edi), `allowBackup=false`.
  Admin: kirish xati shabloni — havola emas, kod (`{{ .Token }}`).
  Testlar: 11 gateway + 7 oqim + 4 chiqish; integratsiya — haqiqiy GoTrue,
  Mailpit'dan kod, `app_bootstrap` shaxsiy byudjetni qaytaradi (BR-010).
- [x] **E14-T02** `app_bootstrap` → byudjetlar (valyutalarda
  `allocation_rounding` — admin tomonda qo'shimcha maydon; domendagi
  `Currency.allocationUnit` shundan). Tanlov: saqlangan byudjet → serverdagi
  oxirgisi → birinchisi; javob nusxasi lokal saqlanadi — **oflaynda ham
  ochiladi** (BR-007), nusxa yo'q bo'lsa qayta urinish ekrani. Boshqa akkaunt
  kirsa lokal ma'lumot tozalanadi. Byudjet yo'q (yoki taklif havolasi
  ochilgan) — "Yangi byudjet" / "Taklif kodi bilan qo'shilish": kod (katta
  harf, 8 belgi), QR (`mobile_scanner`, ML Kit modeli Play xizmatlaridan —
  APK kichik) yoki deep link `<sxema>://invite/<kod>` (flavor bo'yicha
  sxema). Router: splash → qo'shilish → sozlash → ilova. Testlar: 9 startup +
  4 qo'shilish + 3 splash + 4 yo'naltirish; integratsiya —
  `create_household` → `create_invite` → `accept_invite` (bir martalik kod).
- [x] **E14-T03** Onboarding ustasi (har qadamni o'tkazib yuborish mumkin):
  hisoblar + joriy qoldiq → maosh jadvali (daromad turlari: kuni, summa,
  hisob va "qaysi oyga tegishli" — BR-031/BR-040) → doimiy to'lovlar
  (kategoriyalar ro'yxatidan: summa, kun, hisob, avto to'lov) → 👤 fond
  qoidasi (foiz/qat'iy, kun, manba hisob) → yakun. Ro'yxatlar **lokal
  bazadan** (sinxron keltirgan nomlar — server yukni nom bo'yicha topadi),
  kiritilgan qiymatlar yangi ro'yxat kelganda saqlanadi. Yakunda bitta
  `onboarding_apply` + `open_month(joriy)` (oy ochilmasa — sozlash baribir
  saqlanadi, oy keyin "To'lovlar"da ochiladi). Bildirishnoma ruxsati —
  E19-T01 (FCM bilan birga). Yangi: `DirectoryDao`, `MoneyField`
  (raqam + to'liq ko'rinish), `clockProvider` (byudjet vaqt zonasi).
  Testlar: 7 boshqaruvchi + 2 usta oqimi; integratsiya — haqiqiy
  `onboarding_apply` (ikkinchi chaqiruv — `applied: false`) va `open_month`.
- [x] **E14-T04** Ilova qobig'i: yuqorida byudjet almashtirgich (ro'yxat,
  rol, "Yangi byudjet yoki taklif kodi"), `SyncStatusBadge` va profil menyusi
  (chiqish); tagida 4 bo'lim + markaziy FAB; oflayn va texnik ishlar
  bannerlari (`app_config.maintenance` — shartnomada ta'riflandi: til bo'yicha
  matn + `until`); majburiy yangilash ekrani (BR-214 — `min_android_version`
  bilan `package_info_plus` versiyasi solishtiriladi, boshqa ekranlarga
  o'tib bo'lmaydi). Bo'lim sarlavhalari mazmun ichida (qobiqda bitta panel).
  Tuzatildi: byudjet bor bo'lsa ham `/join` ochilaveradi (almashtirgichdan) —
  qo'shilgach ekranning o'zi bosh sahifaga qaytaradi.
- [x] **E14-T05** Ilova qulfi (BR-211): 4 xonali PIN (tuz + PBKDF2, hash
  Keystore bilan shifrlangan xotirada — ochiq saqlanmaydi), biometrika
  (`local_auth`; xato/bekor — PIN qoladi), avto-qulf 1/5/15 daqiqa (fonda
  turgan vaqt bo'yicha), qulf ekrani (PIN esidan chiqsa — chiqish); ilova
  almashtirgichda yashirish — Android `FLAG_SECURE` (MethodChannel,
  `MainActivity`). Maxfiylik rejimi tugmasi qobiqda (BR-212 — `MoneyText`
  allaqachon hurmat qiladi). Tuzatildi: sozlamalar kech o'qilsa
  foydalanuvchi o'zgartirgan holat bosilib ketardi (amallar o'qishni
  kutadi); qulf ochilgach ilovaga qaytariladi. Testlar: 5 birlik
  (PIN, urinishlar, biometrika, sozlamalar) + 2 oqim (PIN o'rnatish →
  avto-qulf → ochish; maxfiylik tugmasi).
- [x] **E14-T06** Testlar: kirish oqimi (7), byudjet tanlash/qo'shilish (13),
  sozlash ustasi (9), qobiq va BR-214 (7), qulf (7); integratsiya —
  **yangi foydalanuvchi: email kodi (Mailpit) → sozlash ustasi → dashboard**
  ilovaning o'zida (haqiqiy server, sinxron). Topilgan xato: sozlash
  oynasida sinxron ishlamasdi (rejalashtiruvchini hech kim kuzatmasdi) —
  byudjet tanlangach ishga tushadi. Host'da `testWidgets` HTTP so'rovlarni
  soxtalashtiradi va fake-async ishlatadi: `HttpOverrides.global = null` +
  `runAsync` bilan haqiqiy tarmoq (izoh testda).

### E15 · Amallar `[mobile]`

> **Qoidalar:** BR-009, BR-040..056, BR-061..062, BR-140..142, BR-201..202.
> **DoD:** xarajat 3 bosishda (tez tugma — 1 bosish), undo ishlaydi,
> oflaynda to'liq ishlaydi.

- [x] **E15-T01** "Qo'shish" varag'i: Xarajat/Daromad/O'tkazma segmenti,
  `AmountKeypad` (`000`, `⌫`, oddiy `+ −` hisob, haptic), summa jonli
  formatlanadi (byudjet valyutasida). Kiritish mantiqi — sof `AmountEntry`
  (5 test), varaq — 3 vidjet testi.
- [x] **E15-T02** Maydonlar: kategoriya to'ri (oxirgi 8 tasi oldinda,
  8 dan ko'p bo'lsa qidiruv, joyida yangi kategoriya — BR-035, domen
  `CreateCategory`: nom 1–60, shu nomlisi bo'lsa o'sha — BR-003), hisob
  chiplari, sana (Bugun/Kecha/kalendar), payee avto-to'ldirish + oxirgi
  kategoriya/hisob taklifi (BR-056), izoh, teglar (`transaction_tags` —
  amal bilan bitta tranzaksiyada, outbox), qarz bog'lash. Xatolar maydon
  bo'yicha aniq matn; yopilgan oy (BR-055) — qat'iy bo'lmasa tasdiq bilan
  yoziladi. Saqlash oflaynda ishlaydi (lokal + outbox).
- [x] **E15-T03** Tegishli oy: jonli izoh ("→ Sentabr 2026 oyining daromadi
  sifatida yoziladi (oldingi oy)" — domen `attributeBudgetMonth`, daromad
  kategoriyasi siljishi bilan), "Qaysi oyning byudjetiga?" chiplari (Sana
  bo'yicha / Oldingi oy / Tanlash — 12 oy ro'yxati); daromadda ham (BR-042).
  Tanlangan oy `manual` bo'lib saqlanadi; tur o'zgarsa bekor. 4 holat testi.
- [x] **E15-T04** Tez tugmalar qatori (xarajat varag'i tepasida, hisob
  valyutasida summa): bosish → darhol saqlash (`source = quick_action`),
  varaq yopiladi + 5 s "Bekor qilish" (serverga yetmagan bo'lsa navbatdan
  ham chiqadi); uzoq bosish → to'ldirilgan forma (BR-141). Yopilgan oy —
  tasdiq bilan.
- [x] **E15-T05** O'tkazma: manba/manzil hisob (manzilda manba yo'q),
  👤 izohlari: fondga — "ajratma sifatida hisoblanadi", fonddan — "ajratmaning
  qaytishi" (BR-061), fonddan xarajat — "oylik qoldiqqa ta'sir qilmaydi",
  kategoriyasiz bo'lsa "O'zim uchun" (BR-062); daromadda fond hisobi
  ko'rsatilmaydi (BR-063). Turli valyutali o'tkazma (ikkinchi summa) — E29,
  hozircha aniq xabar.
- [x] **E15-T06** Amallar ro'yxati: oy almashtirgich (tegishli oy bo'yicha —
  `transactions_month` indeksi, EXPLAIN bilan tekshirilgan), kun bo'yicha
  guruh + kunlik daromad/xarajat (bir o'tishda), qidiruv (joy/izoh
  registrsiz, raqam — summa), filtr chiplari (turi, kategoriya, hisob —
  o'tkazmaning ikkala tomoni, teg — `EXISTS`), sahifalash (LIMIT oshadi,
  reaktiv), swipe → o'chirish + 5 s undo (BR-009), bosish → tahrirlash
  (o'sha forma, tur o'zgarmaydi; qo'lda oy saqlanadi); yopilgan oy banneri
  va tasdig'i (BR-055). A'zo filtri — E30 (a'zolar ro'yxati sinxronda yo'q).
  Testlar: 6 filtr (DAO) + 4 ekran.
- [x] **E15-T07** Chek rasmi (BR-201): kamera/galereya (`image_picker`),
  JPEG'ga siqish ≤ 1 MB (sifat/o'lcham bosqichma-bosqich; sig'masa — xabar),
  lokal navbat — `pending_uploads` jadvali (sxema v2, migratsiya testi:
  jadval + indeks, ma'lumot saqlanadi), fayl ilova hujjatlarida; yuklash har
  sinxron siklida push'dan oldin (`{household}/{tx}/{id}.{ext}`), so'ng
  `attachments` qatori outbox orqali; tarmoq yo'q — navbatda qoladi.
  Tahrirlashda mavjud cheklar (Storage — vaqtinchalik havola) va navbatdagilar
  ko'rinadi, o'chirish/bekor qilish; ko'rish — `InteractiveViewer` (zoom).
  Testlar: 7 navbat/siqish + 2 forma; integratsiya — haqiqiy Storage'ga
  yuklash, `attachments` serverda, fayl qayta o'qiladi (CI'da Storage yoqildi).
- [x] **E15-T08** Testlar: forma validatsiyasi (kategoriya, o'tkazma manzili,
  xabarlar), tegishli oy izohi (4 holat), undo (tez tugma va o'chirish), tez
  tugma (bosish/uzoq bosish), fond izohlari, cheklar; golden: qo'shish
  varag'i light/dark (360×780, `test/features/transactions/golden/`).
  Jami: 264 ilova + 195 domen testi, qoplama 90,9%; 9 integratsiya testi.

### E16 · Xulosa (dashboard) va hisobotlar `[mobile]`

> **Qoidalar:** BR-005, BR-090..103, BR-112..114, BR-121, BR-130.
> **DoD:** dashboard serverga so'rovsiz ochiladi (< 300 ms lokal hisob),
> raqamlar admin `report_month` bilan bir xil (fixture'lar).

- [x] **E16-T01** `MonthReportLoader` (lokal `report_month`): drift
  `month_facts` + yangi `ReportDao` (kategoriya — server qoidasi bilan:
  rejasi, fakti yoki limiti bor, ota-kategoriya subkategoriyalar bilan;
  daromad turlari; ochiq rejalar; daromad rejalari; oy holati) → domen
  hisoblari; jadvallar o'zgarsa qayta hisoblanadi. Oy almashtirish (surish +
  ‹ ›), ochilmagan → "Oyni ochish" (preview → tasdiq → `open_month` →
  sinxron), 🔒 yopilgan. **Parite: 49 fixture holati — lokal hisob =
  admin `report_month`** (ikki farq topildi va tuzatildi).
- [x] **E16-T02** Hero karta: QOLDIQ (manfiy — qizil), prognoz qoldiq,
  "Oy oxirida ≈ X", **"Kuniga ≈ Y so'm"** (joriy oy, BR-094), orttirgan %
  halqasi; maxfiylik rejimida `•••`.
- [x] **E16-T03** Bloklar: 4 stat (daromad, xarajat, karta, naqd — bosilsa
  filtrlangan amallar), reja bajarilishi (`X so'm + N ta ?`), yaqin 3 to'lov
  (bir bosishda "To'landi" — `PayPlanned`, yopilgan oy tasdig'i),
  kategoriyalar (limit rangi, `2 000 000 (100%)`), daromad turlari
  (karta/naqd), 👤 fond va 🏦 jamg'arma **alohida** plitalar (BR-005), qarz
  va maqsad qisqacha.
- [x] **E16-T04** Prognoz kartasi (BR-093): o'tgan kunlar `16 / 30`, kunlik
  sarf, oy oxiri sarfi, kutilayotgan daromad + "hozircha kelgani …" izohi.
- [x] **E16-T05** Yillik ko'rinish (`/reports/year`): oylar ro'yxati
  (daromad, xarajat, qoldiq, orttirgan %, 🔒), ustun grafik (`MonthBars`,
  CustomPaint), JAMI — `report_year` fixture'i bilan parite; oy bosilsa —
  o'sha oy Xulosasi. Kategoriya tafsiloti (`/reports/category/:id`): 12 oylik
  trend (subkategoriyalar bilan), shu kategoriya amallariga o'tish. Tor
  ekranda toshib ketish xatolari tuzatildi (test topdi).
- [x] **E16-T06** Oylik hisobotni ulashish: oldindan ko'rish + PNG
  (`RepaintBoundary` → 360 px karta ×3 = 1080 px; `share_plus`). Karta —
  qoldiq, orttirgan %, daromad/xarajat, karta/naqd, eng katta 5 xarajat;
  maxfiylik rejimida `•••`. PDF — kerak emas (rasm messenjerda qulayroq).
- [x] **E16-T07** Testlar: controller — `report_month`/`report_year`
  fixture'lari bilan parite (T01, T05); golden: hero (musbat, manfiy/dark,
  maxfiy), bo'sh oy (yangi `EmptyState` — oyga bog'liq bo'lmagan fond/qarz/
  maqsadlar qoladi), ulashish kartasi. Golden "oyni ochish" kartasida tor
  ekranda matn siqilishini ko'rsatdi — ustma-ust joylashuvga o'tkazildi.

### E17 · To'lovlar (rejalar) `[mobile]`

> **Qoidalar:** BR-070..085, BR-113. **DoD:** eski "⏳ To'lov" bo'limidagi
> hamma narsa + qisman to'lov, o'tkazib yuborish, kalendar.

- [x] **E17-T01** Ro'yxat (`/payments`): Xarajatlar / Kutilayotgan
  daromadlar tablari; bo'limlar ⚠️ kechikkan · 📌 bugun · 🗓 yaqin (3 kun,
  BR-160 standarti) · keyinroq · ✅ to'langan / kelgan (yig'ilgan) · ⏭
  o'tkazilgan; sarlavhada `To'lanmagan: X so'm + N ta ?`. Bo'limlar va jami —
  domen `PlanBoard` (sof, testlangan); ma'lumot — `watchMonthPlans`
  (`planned_items_month` indeksi, reaktiv).
- [x] **E17-T02** `PlanTile`: holat belgisi/rangi, nom, avto to'lov va qarz
  belgilari, sana · kategoriya, qolgan summa yoki `? · Summa o'zgaruvchi`,
  qisman progress (`to'langan / reja`); "To'landi"/"Keldi" → varaq (summa —
  standart qolgan, `?` da majburiy; hisob — fondsiz; sana); swipe → qolgan
  summa bilan darhol; menyu → shu oy summasi (`EditPlan`, BR-083), yopish /
  qayta ochish (`ClosePlan`), o'tkazib yuborish (+ bekor qilish).
- [x] **E17-T03** Qisman to'lov dialogi (BR-073): "Qolgan X ni keyin
  to'laysizmi?" → qisman / "Yopish" (`settle`); daromad rejasi → "Keldi"
  (daromad amali, tegishli oy — reja oyi).
- [x] **E17-T04** "Oyni ochish" (Xulosa va To'lovlarda bitta `OpenMonthCard`):
  preview varag'i (yaratiladigan rejalar ro'yxati, allaqachon borlar soni) →
  tasdiq → server RPC → sinxron; oflaynda "Internet yo'q" xabari.
- [x] **E17-T05** Kalendar: oy to'ri (hafta boshi — lokal), kunlarda holat
  rangidagi nuqtalar, kun bosilsa — shu kun rejalari.
- [x] **E17-T06** Testlar: domen — `PlanBoard` chegaralari (kecha/bugun/N
  kun/keyin), `ClosePlan`/`EditPlan`/`SkipPlanned` (yopilgan oy: tasdiq,
  qat'iy qulf); vidjet — bo'limlar va jami, qisman → keyin / yopish → qayta
  ochish, `?` summa majburiy, swipe, o'tkazish + undo, shu oy summasi, "Keldi",
  kalendar, oyni ochish (onlayn/oflayn); goldenlar (ro'yxat, kalendar/dark).
  Testlar topgan xatolar: tahrir dialogi eski qiymatni saqlashi (yopilish
  closure'i), tor ekranda tugmalar/progress toshib ketishi.

### E18 · Hamyon `[mobile]`

> **Qoidalar:** BR-020..025, BR-060..065, BR-100..103, BR-110..123,
> BR-130..134. **DoD:** eski "🏦 Fondlar" bo'limining hammasi + hisoblar,
> o'tkazmalar, limitlar.

- [ ] **E18-T01** Hisoblar: turlari bo'yicha guruh, qoldiqlar, jami (valyuta
  bo'yicha), manfiy naqd ogohlantirishi (BR-025), hisob tafsiloti (harakatlar
  ro'yxati), "O'tkazma" tugmasi.
- [ ] **E18-T02** 👤 Shaxsiy fond: qoldiq, shu oy va jami ajratilgan/
  sarflangan, "Sarf qo'shish" (fond hisobidan xarajat — BR-062), tarix,
  ajratma rejasi holati (`percent` rejimida jonli summa).
- [ ] **E18-T03** 🏦 Jamg'arma: jami, to'planish chizig'i, oylar jadvali
  (daromad, xarajat, shu oy qolgan, to'plangan, ⏳ joriy oy), izoh: "pul
  jismonan qayerda — Hisoblar bo'limida" (BR-103).
- [ ] **E18-T04** 💳 Qarzlar: men qarzdorman / menga qarzdor / ⚖️ sof holat,
  oylik majburiyat; element: progress, qolgan, tugash oyi, 3 holat (BR-116),
  kutilmoqda summasi; tafsilot: bog'langan to'lovlar; qo'shish/tahrirlash
  (member huquqi bilan).
- [ ] **E18-T05** 🎯 Maqsadlar: progress, oyiga, "N oy (YYYY-MM)", ulguradimi
  belgisi, hisobga bog'lash yoki qo'lda summa; yig'ilganda tabrik animatsiyasi.
- [ ] **E18-T06** 📊 Limitlar (byudjet boshqaruvi): kategoriyalar limit
  progressi, limit summasini o'zgartirish (owner/admin), 80/100% ranglar.
- [ ] **E18-T07** Testlar: fond va jamg'arma **hech qayerda qo'shilmasligi**
  (BR-005) — widget testi; qarz/maqsad holatlari.

### E19 · Bildirishnomalar va sozlamalar `[mobile]`

> **Qoidalar:** BR-015, BR-160..168, BR-211..214. Bog'liqlik: E11 (admin).

- [ ] **E19-T01** FCM: ruxsat so'rash (onboarding'da), token → `register_device`,
  token yangilanishi, foreground ko'rsatish, bildirishnomani bosish → tegishli
  ekran (deep link: to'lovlar / oylik hisobot / limit kategoriyasi).
- [ ] **E19-T02** Lokal eslatmalar (BR-168): yaqin 14 kun rejalari uchun
  qurilmada `zonedSchedule` (eslatma soati), ma'lumot o'zgarsa qayta
  rejalashtirish, ≤ 30 ta.
- [ ] **E19-T03** Bildirishnoma sozlamalari: push, Telegram (ulash:
  `telegram_link_token` → `t.me/<bot>?start=…` ochish, holat), email, soat,
  necha kun oldin, oylik hisobot kuni, limit ogohlantirishlari.
- [ ] **E19-T04** Sozlamalar ekrani: profil, byudjetlar, tema (tizim/och/
  to'q), til, ilova qulfi, maxfiylik rejimi, sinxron holati, eksport (JSON
  ulashish), "Akkauntni o'chirish" (`delete-account`, ikki bosqichli tasdiq),
  ilova haqida (versiya, litsenziyalar).
- [ ] **E19-T05** Testlar: deep link marshrutlari, lokal eslatma
  rejalashtiruvchisi (fake clock).

### E20 · Sifat, sayqal, reliz konveyeri `[mobile]`

> **DoD:** v1.0 reliz nomzodi: Crashlytics'da 7 kun crash yo'q (testerlar),
> sovuq start < 2 s, e2e yashil, APK avtomatik tarqatiladi.

- [ ] **E20-T01** Ikon va splash (flavor ranglari), ilova nomi 3 tilda,
  Android adaptiv ikon, monoxrom ikon (Android 13+).
- [ ] **E20-T02** Ishlash: sovuq start o'lchovi (`--profile`), kechiktirilgan
  init, ro'yxatlar 60 fps (DevTools), rasm keshi; natija `docs/PERF.md`.
- [ ] **E20-T03** Qulaylik (a11y): semantika (summalar o'qiladi), kontrast,
  200% matn, TalkBack bilan asosiy oqimlar.
- [ ] **E20-T04** E2E (patrol, emulyator): onboarding → xarajat → to'lov →
  dashboard; oflayn → onlayn sinxron. CI: har kecha (KVM'li Linux runner).
- [ ] 🔑 **E20-T05** Imzolash: upload keystore (sirlar — `DEPLOY.md`),
  `key.properties` CI'da yaratiladi; ProGuard/R8 qoidalari.
- [ ] 🔑 **E20-T06** `android.yml`: `main` → staging APK → Firebase App
  Distribution ("testers" guruhi) + artefakt; build raqami = `run_number`.
- [ ] 🔑 **E20-T07** `release.yml`: `v*` teg → prod APK + AAB → GitHub Release
  (CHANGELOG bilan) + App Distribution; ixtiyoriy: Google Play internal track
  (Play akkaunti bo'lsa).
- [ ] **E20-T08** Reliz nomzodi `v1.0.0-rc.1` → testerlar → `v1.0.0` (E28).

---

## Kengaytmalar (M5) — mobil qismlar

### E29 · Ko'p valyuta — mobil qismi

- [ ] **E29-T07** Hisob valyutasi tanlash, amal formasida valyuta belgisi,
  asosiy valyutadagi ekvivalent (`≈ 1 265 000 so'm`), qo'lda kurs maydoni.
- [ ] **E29-T08** O'tkazma: ikki valyuta — ikkinchi summa va kurs jonli
  hisobi (BR-193); lokal `amount_base` taxmini (lokal kurslar jadvali
  `sync_pull` orqali), server kanonik qiymati bilan almashtiriladi.
- [ ] **E29-T09** Hamyon: valyutalar bo'yicha jami + asosiy valyutadagi jami;
  fixture'lar (E29-T05) bilan testlar.

### E30 · Oilaviy byudjet — mobil qismi

- [ ] **E30-T04** A'zolar ekrani: ro'yxat, rollar, taklif (kod, havola,
  QR, ulashish), chiqish/chiqarish (owner/admin).
- [ ] **E30-T05** "Kim yozdi" — amal elementida a'zo avatari, filtrda a'zo,
  dashboard'da a'zolar kesimi (ixtiyoriy blok).
- [ ] **E30-T06** Rolga qarab UI: `viewer` — faqat o'qish, `member` —
  spravochnik tahriri yo'q.

### E32 · Tahlillar — mobil qismi

- [ ] **E32-T03** Dashboard'da "Diqqat" kartalari (kategoriya sakrashi,
  yangi obuna aniqlandi) — lokal hisob yoki `report_insights` keshi.
- [ ] **E32-T04** "Yil xulosasi" ekrani (yil oxirida/boshida taklif qilinadi).

### E33 · Android vidjet va chek QR skaneri `[mobile]`

- [ ] **E33-T01** Bosh ekran vidjeti (`home_widget`): joriy oy qoldig'i,
  "kuniga ≈ X", "＋" tugmasi (qo'shish varag'iga deep link); maxfiylik
  rejimini hurmat qiladi.
- [ ] **E33-T02** Chek QR skaneri (`mobile_scanner`): soliq.uz fiskal chek
  havolasidan summa/sana/sotuvchini ajratish → xarajat formasi to'ldiriladi;
  tanilmasa — faqat havola izohga.
- [ ] **E33-T03** Tez amallar (app shortcuts): "Xarajat", "Daromad",
  "To'lovlar" — ikonni uzoq bosganda.

### E34 · Limitlar v2 — mobil qismi

- [ ] **E34-T03** Ota-kategoriya limiti va rollover ko'rinishi (mavjud limit =
  limit + o'tgan oydan qolgan), fixture'lar bilan testlar.

---

## Jarayon jurnali (mobil)

| Sana | Vazifa | Natija |
|---|---|---|
| 2026-09-18 | E00 | mobil arxitektura, reja, deploy yo'riqnomasi va CONTRIBUTING yozildi |
| 2026-09-18 | E04-T01 | Flutter loyiha (Android), `uz.mywallet.app`, workspace + `wallet_domain`, very_good_analysis, `make check` yashil, debug APK ✅ |
| 2026-09-18 | E04-T02..T03 | flavor'lar (dev APK: `uz.mywallet.app.dev`, "My Wallet Dev" ✅), AppConfig (+test), bootstrap (xato ushlagichlar, AppLog, ProviderScope) |
| 2026-09-18 | E04-T04 | dizayn tokenlari, tema, formatMoney (+6 test), MoneyText (+3 vidjet testi), AppCard/EmptyState/Skeleton, dev katalog |
| 2026-09-18 | E04-T05 | gen-l10n (uz asosiy, ru, en; `AppL10n`), noma'lum qurilma tili → uz, oy sarlavhasi admin bilan bir xil (+4 test) |
| 2026-09-18 | E04-T06 | go_router shell (4 tab + notched ＋), /add, 404, dev katalog; 20 test yashil |
| 2026-09-18 | E04-T07 | mobil CI (dart + android job'lari), qoplama chegarasi skripti (88,4% ≥ 70%) |
| 2026-09-18 | E04-T08 | contracts/ admin 5f95b9a dan olindi, lock + yaxlitlik tekshiruvi. **E04 yakunlandi** |
| 2026-09-19 | E12-T01..T06 | `wallet_domain`: value object'lar, 12 entity, 14 qoida moduli, 9 use-case; golden fixture pariteti 51/51 (mutatsiya testi bilan). **E12 yakunlandi** |
| 2026-09-19 | E13-T01..T07 | drift sxemasi (14 jadval + outbox/kursor/muammolar), `LedgerDao` (oy yig'indisi SQL'da — domen bilan parite 52/52), `RemoteApi`, repository'lar (qator + outbox atomar), `SyncEngine`/`SyncScheduler`, WorkManager, holat nishoni va ekrani; 155 test (qoplama 92,5%), domen 192 (97,7%); lokal Supabase bilan 4 integratsiya testi — drift upsert NULL xatosini topdi. **E13 yakunlandi** |
| 2026-09-20 | E14-T01..T06 | kirish (email kodi, Google + nonce; sessiya shifrlangan xotirada), byudjet yuklash/tanlash va taklif bilan qo'shilish (QR, deep link), sozlash ustasi (`onboarding_apply` + joriy oy), qobiq (almashtirgich, bannerlar, BR-214), ilova qulfi (PIN/PBKDF2, biometrika, avto-qulf, FLAG_SECURE) va maxfiylik rejimi; 221 test (92,6%), 8 integratsiya testi. **E14 yakunlandi** |
| 2026-09-21 | E15-T01..T08 | "Qo'shish" varag'i (klaviatura, tez tugmalar + undo, kategoriya/hisob/sana/joy/teg/qarz, joyida kategoriya, tegishli oy izohi, fond izohlari, cheklar — siqish, oflayn navbat, Storage), amallar ro'yxati (oy, kunlik jami, filtr, qidiruv, swipe-o'chirish + undo, tahrirlash); lokal sxema v2 (migratsiya testi indeks xatosini ushladi); 264 test (90,9%), goldenlar, 9 integratsiya. **E15 yakunlandi** |
| 2026-09-21 | E16-T01..T07 | Xulosa lokal bazadan (tarmoqsiz): `MonthReportLoader` + `ReportDao` — `report_month` bilan parite 49/49, `report_year` jami; hero (qoldiq, prognoz, kuniga, orttirgan %), statistika → filtrlangan amallar, rejalar, yaqin to'lovlar (To'landi), prognoz, kategoriyalar (limit rangi), daromad turlari, fond/jamg'arma, qarz, maqsadlar; oyni ochish; yillik ko'rinish + kategoriya trendi; PNG ulashish; bo'sh oy holati; 328 test (89,1%), goldenlar tor ekran xatolarini topdi. **E16 yakunlandi** |
| 2026-09-21 | E17-T01..T06 | To'lovlar: tablar (xarajat/daromad), holat bo'limlari va `X + N ta ?` jami (`PlanBoard`), to'lash varag'i (qolgan summa, `?` majburiy, hisob/sana), qisman → keyin/yopish, swipe, shu oy summasi, yopish/qayta ochish, o'tkazish + undo, kalendar, oyni ochish preview'i (umumiy `OpenMonthCard`); domen: `ClosePlan`, `EditPlan`, reja o'zgarishlarida yopilgan oy tekshiruvi; umumiy `MonthSwitcher`; 341 test (91,4%), domen 203 (97,8%), goldenlar. **E17 yakunlandi** |
