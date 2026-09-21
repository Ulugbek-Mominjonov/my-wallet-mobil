# My Wallet mobil — build va reliz sozlamalari

> Umumiy akkauntlar (Supabase, Firebase, Google OAuth, Telegram):
> `my-wallet-admin/docs/DEPLOY.md`. Bu yerda — faqat mobilga xos qadamlar.
> **Hammasi bepul.** 💲 — ixtiyoriy pullik.

---

## 1. Lokal muhit

| Vosita | Versiya | Tekshiruv |
|---|---|---|
| Flutter | `.fvmrc` / CI dagi pinned versiya | `flutter --version` |
| Android SDK + platform-tools | API 35+ | `flutter doctor` |
| Java | 17 (Gradle uchun) | `java -version` |
| Docker | lokal Supabase uchun | `docker ps` |

```bash
cp env/dev.example.json env/dev.json     # SUPABASE_URL = http://<kompyuter-IP>:54321
make gen                                   # build_runner
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

> Emulyatordan lokal Supabase'ga: `http://10.0.2.2:54321`; haqiqiy
> telefondan — kompyuterning Wi-Fi IP manzili.

---

## 2. Imzolash kaliti (upload keystore) — bir marta

```bash
keytool -genkeypair -v -keystore upload.jks -alias upload \
  -keyalg RSA -keysize 4096 -validity 10000
base64 -w0 upload.jks > upload.jks.b64
keytool -list -v -keystore upload.jks -alias upload   # SHA-1 va SHA-256
```

- `upload.jks` va parollar — **parol menejeri + oflayn nusxa**. Yo'qolsa,
  o'rnatilgan ilovalarni yangilab bo'lmaydi (yangi paket nomi kerak bo'ladi).
- SHA-1 → Google OAuth Android client'lari va Firebase Android ilovalari
  (admin `DEPLOY.md` 3.3 va 6.2).
- Repoga **hech qachon** qo'yilmaydi (`.gitignore`: `*.jks`, `key.properties`).

---

## 3. Flavor konfiguratsiyasi

| Flavor | `applicationId` | Backend | Tarqatish |
|---|---|---|---|
| `dev` | `uz.mywallet.app.dev` | lokal Supabase | faqat lokal |
| `staging` | `uz.mywallet.app.stg` | Supabase staging | App Distribution (`testers`) |
| `prod` | `uz.mywallet.app` | Supabase prod | GitHub Release + App Distribution (💲 Play) |

`env/<flavor>.json` (CI GitHub o'zgaruvchilaridan yaratadi):

```json
{
  "APP_ENV": "staging",
  "SUPABASE_URL": "https://<ref>.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_...",
  "GOOGLE_WEB_CLIENT_ID": "....apps.googleusercontent.com",
  "AUTH_REDIRECT": "mywallet-stg://auth-callback",
  "TELEGRAM_BOT_USERNAME": "MyWalletStgBot"
}
```

**Deep link sxemasi** (`build.gradle.kts` → `deepLinkScheme`): `mywallet-dev`,
`mywallet-stg`, `mywallet` — taklif havolasi `<sxema>://invite/<kod>` va auth
qaytishi (`AUTH_REDIRECT`). Bir telefonda uchala versiya aralashmaydi.

**Push (FCM, E19):** `google-services.json` va Gradle plagini ishlatilmaydi —
Firebase Dart'dan env qiymatlari bilan ishga tushadi: `FIREBASE_API_KEY`,
`FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`
(Firebase → Project settings → Android ilova, flavor'ning `applicationId`si
bilan). Bo'sh qoldirilsa (dev) — push o'chiq, lokal eslatmalar ishlaydi.

---

## 4. GitHub sirlari (mobil repo)

| Nomi | Turi | Environment | Qayerdan |
|---|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | secret | repo | 2-qadam |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | secret | repo | 2-qadam |
| `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` | variable | staging / production | admin `DEPLOY.md` 2.2 |
| `GOOGLE_WEB_CLIENT_ID` | variable | repo | admin `DEPLOY.md` 3 |
| `GOOGLE_SERVICES_JSON` (base64) | secret | staging / production | admin `DEPLOY.md` 6.2 |
| `FIREBASE_APP_ID_ANDROID` | variable | staging / production | Firebase → Project settings → Android app ID |
| `FIREBASE_APPDIST_SA` (base64) | secret | staging / production | admin `DEPLOY.md` 6.4 |
| `TELEGRAM_BOT_USERNAME` | variable | staging / production | admin `DEPLOY.md` 7 |
| `ADMIN_REPO_TOKEN` | secret | repo | admin `DEPLOY.md` 1.4 (contracts + integratsiya testlari) |

---

## 5. Reliz jarayoni

**Staging (avtomatik):** `main` ga merge → `android.yml` → imzolangan
staging APK → Firebase App Distribution (`testers`) → testerlarga email
(birinchi marta "App Tester" ilovasini o'rnatish taklif qilinadi).

**Production:**
1. `CHANGELOG.md` yangilangan, `pubspec.yaml` versiyasi (`1.2.0+<build>`).
2. `git tag v1.2.0 && git push --tags` → `release.yml`:
   prod APK + AAB → **GitHub Release** (APK biriktirilgan) + App Distribution.
3. Telefonga o'rnatish: GitHub Release'dan APK → "Noma'lum manbalardan
   o'rnatish"ga ruxsat → o'rnatish. Keyingi versiyalar ilova ichidagi
   "Yangilanish bor" oynasi orqali (min versiya — `app_config`).

💲 **Google Play (ixtiyoriy, $25 bir martalik):** Play Console → ilova
yaratish → Play App Signing → servis akkaunt JSON → `PLAY_SA_JSON` sir →
`release.yml` dagi `play` job'ini yoqish (internal track). Play App Signing
SHA-1 ni Google OAuth'ga qo'shishni unutmang.

💲 **iOS (ixtiyoriy, Apple Developer $99/yil):** kod tayyor; `ios.yml`
(macOS runner, private repoda minutlar ×10) va sertifikatlar alohida
vazifa sifatida qo'shiladi.

---

## 6. Tekshiruv ro'yxati

- [ ] `flutter build apk --flavor staging` lokal ishlaydi (imzo bilan).
- [ ] Google bilan kirish staging APK'da ishlaydi (SHA-1 to'g'ri).
- [ ] App Distribution'dan o'rnatilgan ilova staging backendga ulanadi.
- [ ] Push (FCM) test xabari keladi.
- [ ] Crashlytics'da test crash ko'rinadi (Sozlamalar → Diagnostika → "Test crash", faqat staging).
- [ ] Prod APK GitHub Release'da, versiya raqami to'g'ri.
