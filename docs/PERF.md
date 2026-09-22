# Ishlash (performance) — mobil ilova

> E20-T02. DoD (E20): sovuq start < 2 s. Server hisobotlari va DB yuklamasi —
> admin repo `docs/PERF.md`.

## Sovuq start

**Usul.** `tool/measure_startup.sh <nom> 5` — `flutter run --profile
--trace-startup` (dev flavor), har ishga tushirish yangi jarayon (`force-stop`
+ o'rnatish), `build/start_up_info.json` dan mediana. Holat — kirmagan
foydalanuvchi (kirish ekrani; sessiya tiklash va lokal baza ochilishi ham
shu yo'lda). Profil rejimi — reliz bilan bir xil AOT kod, faqat kuzatuv yoqilgan.

**Muhit.** Android emulyator (API 35, x86_64, 4 GB RAM, **dasturiy GPU** —
swiftshader), lokal Supabase, Flutter 3.47.4, 2026-09-22. Dasturiy chizish
tufayli mutlaq raqamlar haqiqiy qurilmadan sekinroq — maqsad bilan
solishtirish uchun yuqori chegara.

| Ko'rsatkich (mediana, n = 5) | Oldin (ketma-ket init) | Keyin (parallel init) |
|---|---|---|
| Framework init | 249 ms | 236 ms |
| Birinchi kadr (framework) | 1 148 ms | 1 267 ms |
| Birinchi kadr ekranda (raster) | 1 499 ms | 1 547 ms |

**Xulosa.** DoD bajarilgan: birinchi kadr ekranda ~1,5 s (< 2 s) — hatto
dasturiy GPU'da. O'zgarish (Supabase sessiyasi, Firebase va sozlamalar
parallel; fon sinxronini ro'yxatdan o'tkazish birinchi kadrdan keyin)
emulyatorda **o'lchanadigan yutuq bermadi** — farq shovqin ichida (n = 5,
birinchi o'rnatishdan keyingi ishga tushirish sekinroq). Sababi: dev'da
Firebase sozlanmagan (init darhol qaytadi), vaqtning asosiy qismi — Supabase
sessiyasini shifrlangan xotiradan tiklash. Kod baribir qoldirildi: soddaroq
(`prepareApp` — E2E ham foydalanadi) va Firebase sozlangan (staging/prod)
yig'ilishda uning init'i Supabase bilan ustma-ust tushadi — bu farq haqiqiy
qurilmada reliz nomzodida (E20-T08) o'lchanadi.

## Ro'yxatlar (60 fps)

Emulyatordagi kadr vaqtlari (dasturiy GPU) haqiqiy qurilmani ko'rsatmaydi —
60 fps tekshiruvi reliz nomzodida haqiqiy qurilmada DevTools (Performance)
bilan (E20-T08). Kod darajasida kafolatlar:

- Amallar ro'yxati — keyset sahifalar (`LedgerDao.pageSize` = 50) va
  `ListView.builder`/sliver: faqat ko'rinadigan qatorlar quriladi, butun tarix
  xotiraga yuklanmaydi (E13-T02).
- Oy yig'indilari va hisobotlar — SQL'da (`GROUP BY`, indeks), `build` ichida
  og'ir hisob yo'q (E13, E16); hisobot jadvallar o'zgarganda qayta hisoblanadi.
- Eksport — `rowid` bo'laklari (500) bilan faylga oqim (E19-T04).

## Rasmlar (chek)

- Kichik rasm ekrandagi o'lchamida dekodlanadi (`cacheWidth` /
  `ResizeImage`, o'lcham × `devicePixelRatio`): 64 dp kichik rasm uchun to'liq
  o'lchamli chek (≤ 1 MB JPEG, uzun tomoni ≤ 1600 px) xotirada saqlanmaydi.
- Storage'ning imzolangan havolasi 50 daqiqa qayta ishlatiladi (muddati 1
  soat): ekranga qaytganda yangi imzo so'rovi yo'q va URL o'zgarmagani uchun
  rasm keshidan olinadi (avval har safar qayta yuklanardi). Xato havola
  saqlanmaydi.
