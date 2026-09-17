# Deploy — mobil ilova (My Wallet)

> Ilova: **My Wallet** · Android `uz.mywallet.app` · iOS `uz.mywallet.app`
>
> ⚠️ Bu ID Play Store'ga chiqqandan keyin **o'zgartirilmaydi**.

Backend (Firestore qoidalari, funksiyalar, cron) — `oylik-byudjet-admin`
repodagi `docs/DEPLOY.md` da.

---

## 0. Oldindan kerak bo'ladi

| Nima | Qayerdan | Narxi |
|---|---|---|
| Firebase loyihasi (`-dev` va `-prod`) | console.firebase.google.com | bepul |
| Play Console akkaunti | play.google.com/console | $25 (bir martalik) |
| Apple Developer (faqat iOS uchun) | developer.apple.com | $99/yil |

---

## 1. Firebase'ni ulash

```bash
npm i -g firebase-tools
dart pub global activate flutterfire_cli
firebase login

cd app
flutterfire configure --project=oylik-byudjet-dev
```

Bu buyruq quyidagilarni **avtomatik** qiladi:
* `app/lib/firebase_options.dart` ni qayta yozadi;
* `android/app/google-services.json` ni yaratadi → shundan keyin
  `build.gradle.kts` dagi Google Services plagini **o'zi yoqiladi**
  (plagin fayl mavjudligiga qarab qo'llanadi);
* `ios/Runner/GoogleService-Info.plist` ni yaratadi.

Keyin Firebase konsolida:
1. **Authentication → Sign-in method → Google** ni yoqing;
2. **Firestore Database → Create database** → lokatsiya `eur3` (Yevropa).

## 2. Google Sign-In uchun SHA fingerprint (MAJBURIY)

Bu qadamsiz Android'da Google bilan kirish **ishlamaydi**:

```bash
# Debug (ishlab chiqish uchun)
cd app/android && ./gradlew signingReport | grep -A2 "Variant: debug"

# Reliz (keystore yaratilgandan keyin, 4-bo'lim)
keytool -list -v -keystore ~/mywallet-release.jks -alias mywallet
```

SHA-1 **va** SHA-256 ni Firebase konsolida:
*Project settings → Your apps → Android → Add fingerprint* ga qo'shing,
so'ng `google-services.json` ni qayta yuklab oling.

> Play App Signing yoqilgan bo'lsa, Play Console bergan SHA'ni ham
> qo'shish kerak (Setup → App signing).

## 3. Ishga tushirib ko'rish

```bash
cd app
flutter run \
  --dart-define=FIREBASE_PROJECT_ID=oylik-byudjet-dev \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID_ANDROID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```

> Qiymatlarni `google-services.json` dan yoki Firebase konsolidan olasiz.
> `flutterfire configure` ishlatilgan bo'lsa, `firebase_options.dart`
> to'g'ridan-to'g'ri ularni o'qiydi va `--dart-define` shart emas.

**Tekshiring:** kirish → daromad qo'shish → aviarejimni yoqing → yana
xarajat qo'shing (qoldiq DARHOL o'zgarishi kerak) → aviarejimni o'chiring
(sinxronlanadi).

## 4. Reliz kaliti

```bash
keytool -genkey -v -keystore ~/mywallet-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias mywallet

cp app/android/key.properties.example app/android/key.properties
# → storePassword, keyPassword, storeFile ni to'ldiring
```

⚠️ `key.properties` va `.jks` `.gitignore` da — **repoga tushmaydi**.
Kalitni yo'qotsangiz ilovani yangilab bo'lmaydi (Play App Signing
yoqilmagan bo'lsa). Zaxira nusxasini xavfsiz joyda saqlang.

## 5. Reliz yig'ish

```bash
cd app
flutter build appbundle --release     # Play Store uchun (.aab)
flutter build apk --release           # to'g'ridan-to'g'ri o'rnatish uchun

# iOS (faqat macOS'da)
cd ios && pod install && cd ..
flutter build ipa --release
```

`key.properties` bo'lmasa release build **debug kalit** bilan imzolanadi —
lokal sinov uchun ishlaydi, Play Store esa rad etadi.

## 6. Play Store

1. Play Console → Create app → nomi **My Wallet**;
2. `.aab` ni Internal testing trekiga yuklang;
3. Data safety formasi: ilova moliyaviy ma'lumot **saqlaydi** (Firestore)
   va uni uchinchi tomonga bermaydi;
4. Screenshot'lar: kamida 2 ta telefon uchun (Xulosa va To'lovlar ekranlari).

## 7. Bildirishnomalar

* **Android** — `google-services.json` qo'yilgach o'zi ishlaydi;
* **iOS** — Apple Developer'da **APNs auth key (.p8)** yaratib, uni
  Firebase konsoliga (*Cloud Messaging → APNs Authentication Key*)
  yuklash kerak, aks holda iOS'da push kelmaydi.

## 8. CI/CD

| Workflow | Qachon | Nima qiladi |
|---|---|---|
| `ci.yml` | har push / PR | domen analiz + 230 test + qoplama (≥95%), fixture drifti, Flutter analiz + testlar, **debug APK yig'ish** |
| `release.yml` | `v*` teg qo'yilganda | imzolangan `.aab` + `.apk` → GitHub Release |

```bash
# Reliz chiqarish:
git tag v1.0.0 && git push origin v1.0.0
```

### GitHub secrets (Settings → Secrets and variables → Actions)

Faqat **reliz** uchun kerak; ularsiz CI ishlaydi, `release.yml` esa
debug kalit bilan yig'adi (Play Store qabul qilmaydi).

| Secret | Qiymat |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 ~/mywallet-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore paroli |
| `ANDROID_KEY_PASSWORD` | kalit paroli |
| `ANDROID_KEY_ALIAS` | `mywallet` |

## ✅ Deploy oldidan tekshiruv

- [ ] `flutterfire configure` bajarilgan (`google-services.json` bor)
- [ ] Firebase Auth'da Google provider yoqilgan
- [ ] SHA-1 va SHA-256 qo'shilgan (debug + reliz)
- [ ] Firestore DB yaratilgan (`eur3`)
- [ ] `firebase deploy --only firestore:rules,firestore:indexes` bajarilgan
      (admin repodan) — **indekslarsiz ro'yxat so'rovlari xato beradi**
- [ ] `key.properties` to'ldirilgan, `.jks` zaxiralangan
- [ ] `flutter build appbundle --release` xatosiz o'tdi
- [ ] Aviarejim testi qo'lda bajarildi
