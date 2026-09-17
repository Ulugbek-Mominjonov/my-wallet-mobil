# 💰 My Wallet — mobil ilova

Flutter ilova (`uz.mywallet.app`) va uning **sof Dart domen qatlami**. Google Sheets ilovasining
(`Code.gs` v28) o'rnini bosadi: offline ishlaydi, agregatni yozuv paytida
yangilaydi, dashboard atigi **2 ta hujjat** o'qiydi.

> **Ishga tushirmoqchimisiz?** → [`docs/YORIQNOMA.md`](docs/YORIQNOMA.md)
> — qadamma-qadam, ~2 soat, har qadamda tekshiruvi bilan.
>
> Admin panel, Cloud Functions, Firestore qoidalari va migratsiya
> skriptlari **alohida repoda**: `oylik-byudjet-admin`.

---

## Tuzilma

```
oylik-byudjet-app/
├── app/                      # Flutter ilova (5 bo'lim + sozlamalar)
├── packages/
│   ├── domain/               # ★ SOF DART — barcha biznes qoidalari
│   │   ├── lib/src/calc/     #   §2 dagi qoidalar, sof funksiyalar
│   │   ├── lib/src/entities/
│   │   ├── lib/src/usecases/
│   │   └── tool/generate_fixtures.dart   # umumiy fixture generatori
│   └── data_firebase/        # Firestore implementatsiyasi (DTO, batch)
├── testdata/                 # ★ Dart ⇄ TS umumiy fixture'lari (KANONIK)
├── tool/check_coverage.py    # qoplama chegarasi tekshiruvi
└── docs/
```

**Bog'liqlik faqat pastga:** `app` → `data_firebase` → `domain`.
`domain` paketi Flutter ham, Firebase ham bilmaydi — shuning uchun barcha
qoidalar soniyalar ichida testdan o'tadi.

## Ishga tushirish

```bash
make get FLUTTER=/path/to/flutter/bin/flutter   # bog'liqliklar
make analyze test                                # analiz + testlar
make coverage                                    # qoplama (calc/ ≥95%)

cd app && flutter run \
  --dart-define=FIREBASE_PROJECT_ID=oylik-byudjet-dev \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID_ANDROID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```

> Haqiqiy loyihada `flutterfire configure` ishlatiladi — u
> `app/lib/firebase_options.dart` ni almashtiradi.

## Testlar

| Nima | Qayerda | Soni |
|---|---|---|
| Domen qoidalari (§2) | `packages/domain/test/` | 230 |
| **Delta ≡ noldan hisoblash** (property) | `test/calc/delta_property_test.dart` | 1000 amal |
| Firestore yozuv/o'qish | `packages/data_firebase/test/` | 18 |
| Ekranlar (widget) | `app/test/` | 13 |

## ⚠️ Fixture'lar — ikkinchi repo bilan shartnoma

`testdata/aggregate-cases.json` **shu repoda yaratiladi** (Dart) va
`oylik-byudjet-admin` repodagi TypeScript porti aynan shu fayl bilan
tekshiriladi. Shuning uchun `packages/domain/lib/src/calc/` o'zgarsa:

```bash
make fixtures                     # 1. shu repoda qayta yaratish
# 2. admin repoda:  make sync-fixtures && npm --prefix packages/calc-ts test
```

CI fixture eskirganini avtomatik ushlaydi (`fixtures` job).

## Nima qayerda emas

| Kerak bo'lsa | Qaysi repoda |
|---|---|
| `firestore.rules`, indekslar | `oylik-byudjet-admin` |
| Cloud Functions, Vercel Cron | `oylik-byudjet-admin` |
| Sheets'dan migratsiya skriptlari | `oylik-byudjet-admin` |
| Eski Apps Script kodi (`Code.gs`) | `oylik-byudjet-admin/legacy/` |

**Yo'riqnoma:** [`docs/YORIQNOMA.md`](docs/YORIQNOMA.md) — 9 qadamlik
to'liq ro'yxat (ikkala repo uchun).
**Texnik tafsilotlar:** [`docs/DEPLOY.md`](docs/DEPLOY.md).

Arxitektura va qabul qilingan qarorlar: [`docs/ARXITEKTURA.md`](docs/ARXITEKTURA.md),
[`docs/QARORLAR.md`](docs/QARORLAR.md).
