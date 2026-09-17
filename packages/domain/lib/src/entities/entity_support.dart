/// `copyWith` da "berilmadi" va "ataylab null qilindi" ni ajratuvchi belgi.
///
/// Nullable maydonlarda (masalan `Expense.actual`) oddiy `null` default
/// yetarli emas: "to'lovni bekor qilish" ham `null` yozishni talab qiladi.
const Object unchanged = _Unchanged();

final class _Unchanged {
  const _Unchanged();
}

/// [given] berilmagan bo'lsa [current] ni qoldiradi.
T? orKeep<T>(Object? given, T? current) =>
    identical(given, unchanged) ? current : given as T?;
