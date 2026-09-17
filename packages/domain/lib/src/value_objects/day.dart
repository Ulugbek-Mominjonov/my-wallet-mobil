/// Sana bilan ishlashda vaqt qismini tashlab yuboradigan yordamchi.
///
/// `Code.gs` da sanalar `yyyy-MM-dd` matniga aylantirilib solishtirilardi —
/// bu yerda ham AYNAN kun aniqligida solishtiriladi, soat-minut ta'sir
/// qilmaydi (aks holda "bugun to'lanadi" to'lov "kechikkan" bo'lib qolardi).
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Ikkala sana bir kunmi?
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// [a] kuni [b] kunidan oldinmi (soat hisobga olinmaydi)?
bool isDayBefore(DateTime a, DateTime b) =>
    dateOnly(a).isBefore(dateOnly(b));

/// [a] kuni [b] kunidan keyinmi?
bool isDayAfter(DateTime a, DateTime b) => dateOnly(a).isAfter(dateOnly(b));

/// Kunlar farqi (a − b).
int daysBetween(DateTime a, DateTime b) =>
    dateOnly(a).difference(dateOnly(b)).inDays;
