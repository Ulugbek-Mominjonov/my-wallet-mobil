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
- [ ] **E13-T02** DAO'lar: reaktiv ro'yxatlar (keyset, 50 tadan), `month_facts`
  agregat so'rovi (serverdagi `private.month_facts` ma'nosida), hisob
  qoldiqlari, qarz/maqsad yig'indilari, payee avto-to'ldirish (oxirgi
  ishlatilganlar). Fixture'lar bilan DAO testlari (in-memory).
- [ ] **E13-T03** `RemoteApi` (Supabase RPC): `app_bootstrap`, `sync_pull`,
  `sync_push`, `open_month`, `open_month_preview`, `onboarding_apply`,
  `accept_invite`, `telegram_link_token`, `register_device`; xatolarni
  `Failure` ga o'girish (`contracts/api.md` kodlari).
- [ ] **E13-T04** Repository'lar: yozish = lokal qator + outbox bitta
  tranzaksiyada; bir qatorning ketma-ket o'zgarishlarini birlashtirish.
- [ ] **E13-T05** `SyncEngine`: push (≤ 100, natijalarni qo'llash), pull
  (sahifalab, outbox'dagi qatorlarni himoya qilish), `resync_required`,
  eksponensial qayta urinish, bir vaqtda faqat bitta sinxron (mutex),
  triggerlar (start, yozuv debounce, tarmoq, resume, pull-to-refresh).
- [ ] **E13-T06** Fon sinxron: Android WorkManager (6 soat, tarmoq sharti);
  `SyncStatus` provider + `SyncStatusBadge` + "Sinxron holati" ekrani
  (outbox soni, oxirgi sinxron, muammolar ro'yxati, "Qayta yuborish",
  "To'liq qayta yuklash").
- [ ] **E13-T07** Integratsiya testlari (`integration_test/sync/`): admin
  repoda `contracts.lock` dagi commit → `supabase start` → 2 "qurilma"
  simulyatsiyasi: offline yozuv → push; bir qatorni ikki qurilmada tahrirlash
  → conflict; rad etiladigan yozuv → qaytarish; o'chirish → tombstone.
  CI: `integration.yml` (PR + har kecha).

### E14 · Auth, onboarding, ilova qobig'i `[mobile]`

> **Qoidalar:** BR-010..012, BR-031, BR-060, BR-080, BR-211, BR-214.
> **DoD:** yangi foydalanuvchi 2 daqiqada sozlab, joriy oy ochilgan holda
> dashboard'ni ko'radi.

- [ ] **E14-T01** Kirish: Google (native → `signInWithIdToken`), email OTP
  (kod kiritish ekrani), xatolar; sessiya `flutter_secure_storage` da;
  chiqish (lokal ma'lumotni tozalash tasdig'i bilan).
- [ ] **E14-T02** `app_bootstrap` → byudjetlar (valyutalarga
  `allocation_rounding` qo'shiladi — admin, qo'shimcha o'zgarish; domendagi
  `Currency.allocationUnit` shundan); birinchi kirishda:
  "Yangi byudjet" yoki "Taklif kodi bilan qo'shilish" (kod / QR / deep link
  `mywallet://invite/<kod>`).
- [ ] **E14-T03** Onboarding ustasi (har qadamni o'tkazib yuborish mumkin):
  hisoblar + boshlang'ich qoldiq → maosh jadvali (Avans/Oylik/KPI/Qo'shimcha:
  kuni va "qaysi oyga tegishli") → doimiy to'lovlar (Ijara, Kommunal,
  Internet… tayyor ro'yxatdan, summa, kun, avto to'lov) → 👤 fond qoidasi
  (10% / qat'iy) → bildirishnoma ruxsati → `onboarding_apply` +
  `open_month(joriy)`.
- [ ] **E14-T04** Ilova qobig'i: pastki navigatsiya + markaziy FAB, byudjet
  almashtirgich, `OfflineBanner`, `SyncStatusBadge`, majburiy yangilash
  ekrani (BR-214), texnik ishlar banneri (`app_config`).
- [ ] **E14-T05** Ilova qulfi: PIN o'rnatish/o'zgartirish, biometrika,
  avto-qulf (1/5/15 daqiqa), qulf ekrani; ilova almashtirgichda yashirish
  (BR-211). Maxfiylik rejimi tugmasi (BR-212).
- [ ] **E14-T06** Widget testlar: onboarding oqimi (fake repo), qulf
  ekrani; integratsiya: yangi foydalanuvchi → onboarding → dashboard.

### E15 · Amallar `[mobile]`

> **Qoidalar:** BR-009, BR-040..056, BR-061..062, BR-140..142, BR-201..202.
> **DoD:** xarajat 3 bosishda (tez tugma — 1 bosish), undo ishlaydi,
> oflaynda to'liq ishlaydi.

- [ ] **E15-T01** "Qo'shish" varag'i: Xarajat/Daromad/O'tkazma segmenti,
  `AmountKeypad` (`000`, `⌫`, oddiy `+ −` hisob), summa formatlash jonli.
- [ ] **E15-T02** Maydonlar: kategoriya to'ri (oxirgi 8 tasi oldinda,
  qidiruv, joyida yangi kategoriya — BR-035), hisob chiplari, sana
  (Bugun/Kecha/kalendar), payee avto-to'ldirish + oxirgi kategoriya/hisob
  taklifi (BR-056), izoh, teglar, qarz bog'lash.
- [ ] **E15-T03** Tegishli oy: jonli izoh ("→ Avgust 2026 oyining daromadi
  sifatida yoziladi (oldingi oy)"), xarajatda "Qaysi oyning byudjetiga?"
  chiplari (Sana bo'yicha / Oldingi oy / Tanlash) — BR-045.
- [ ] **E15-T04** Tez tugmalar qatori: bosish → darhol saqlash + 5 s undo
  snackbar; uzoq bosish → to'ldirilgan forma (BR-141).
- [ ] **E15-T05** O'tkazma: manba/manzil hisob, summa (valyutalar farq qilsa
  ikkinchi summa — E29), 👤 fondga o'tkazma bo'lsa "Bu ajratma sifatida
  hisoblanadi" izohi (BR-061).
- [ ] **E15-T06** Amallar ro'yxati: kun bo'yicha guruh + kunlik jami, oy
  filtri, qidiruv (nom/izoh/summa), filtr chiplari (turi, kategoriya, hisob,
  a'zo, teg), keyset sahifalash, swipe → o'chirish + undo (BR-009), bosish →
  tahrirlash; yopilgan oy ogohlantirishi (BR-055).
- [ ] **E15-T07** Chek rasmi: kamera/galereya, siqish ≤ 1 MB, lokal navbat
  (oflaynda saqlanadi), fon yuklash Storage'ga, ko'rish (zoom).
- [ ] **E15-T08** Testlar: forma validatsiyasi, tegishli oy izohi (4
  holat), undo, tez tugma; golden: qo'shish varag'i light/dark.

### E16 · Xulosa (dashboard) va hisobotlar `[mobile]`

> **Qoidalar:** BR-005, BR-090..103, BR-112..114, BR-121, BR-130.
> **DoD:** dashboard serverga so'rovsiz ochiladi (< 300 ms lokal hisob),
> raqamlar admin `report_month` bilan bir xil (fixture'lar).

- [ ] **E16-T01** `DashboardController`: drift `month_facts` + umumiy
  yig'indilar → domen hisoblari; oy almashtirish (swipe + ‹ ›), oy holati
  (ochilmagan → "Oyni ochish" CTA, 🔒 yopilgan).
- [ ] **E16-T02** Hero karta: QOLDIQ (manfiy — qizil), prognoz qoldiq,
  "Oy oxirida ≈ X", **"Kuniga ≈ Y so'm"** (joriy oy, BR-094), orttirgan %
  halqasi; maxfiylik rejimida `•••`.
- [ ] **E16-T03** Bloklar: 4 stat (daromad, xarajat, karta, naqd — bosilsa
  filtrlangan amallar), reja bajarilishi (`X so'm + N ta ?`), yaqin 3 to'lov
  (bir bosishda "To'landi"), kategoriyalar (limit rangi, `2 000 000 (100%)`),
  daromad turlari (karta/naqd), 👤 fond va 🏦 jamg'arma **alohida** plitalar,
  qarz va maqsad qisqacha.
- [ ] **E16-T04** Prognoz kartasi (BR-093): o'tgan kunlar `16 / 30`, kunlik
  sarf, oy oxiri sarfi, kutilayotgan daromad + "hozircha kelgani …" izohi.
- [ ] **E16-T05** Yillik ko'rinish: oylar ro'yxati (daromad, xarajat, qoldiq,
  orttirgan %, 🔒), ustun grafik, JAMI; kategoriya tafsiloti (oyma-oy trend,
  shu kategoriya amallari).
- [ ] **E16-T06** Oylik hisobotni ulashish: rasm (vidjetni PNG ga) yoki PDF.
- [ ] **E16-T07** Testlar: fixture'lar bilan controller testlari; golden:
  hero karta (musbat/manfiy/maxfiy), bo'sh oy holati.

### E17 · To'lovlar (rejalar) `[mobile]`

> **Qoidalar:** BR-070..085, BR-113. **DoD:** eski "⏳ To'lov" bo'limidagi
> hamma narsa + qisman to'lov, o'tkazib yuborish, kalendar.

- [ ] **E17-T01** Ro'yxat: Xarajatlar / Kutilayotgan daromadlar tablari;
  bo'limlar ⚠️ kechikkan (qizil) · 📌 bugun · 🗓 yaqin (N kun) · keyinroq ·
  ✅ to'langan (yig'ilgan) · ⏭ o'tkazilgan; sarlavhada jami `X so'm + N ta ?`.
- [ ] **E17-T02** Element: nom, kategoriya ikoni, sana, reja (yoki `?`),
  avto to'lov / qarz belgilari, qisman to'langan progress; summa maydoni +
  "To'landi" (standart — qolgan summa; `?` bo'lsa summa majburiy); swipe →
  to'liq to'lash; menyu → o'tkazib yuborish, tahrirlash (shu oy uchun summa).
- [ ] **E17-T03** Qisman to'lov dialogi (BR-073): "Qolganini keyin
  to'laysizmi?" → `partial` / "Yopish"; kutilayotgan daromad → "Keldi"
  (daromad amali, tegishli oy — reja oyi).
- [ ] **E17-T04** "Oyni ochish": preview varag'i (yaratiladigan rejalar,
  allaqachon borlar soni) → tasdiq → server RPC (onlayn talab qilinadi —
  oflaynda tushunarli xabar).
- [ ] **E17-T05** Kalendar ko'rinishi: oy to'ri, kunlarda nuqtalar (holat
  rangi), kunni bosish → shu kun rejalari.
- [ ] **E17-T06** Testlar: holat hisoblari (bugun/kecha/ertaga chegaralari),
  to'lash oqimlari, `?` holati.

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
