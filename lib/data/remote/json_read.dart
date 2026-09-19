/// Server javobini qat'iy o'qish: tur mos kelmasa — `FormatException`
/// (shartnoma buzilgan — jimgina noto'g'ri qiymat emas).
typedef Json = Map<String, Object?>;

T read<T>(Json json, String key) {
  final value = json[key];
  if (value is T) return value;
  throw FormatException('`$key`: $T kutilgan', value);
}

Json readObject(Json json, String key) => read<Map<String, Object?>>(json, key);

List<Json> readObjects(Json json, String key) => [
  for (final item in read<List<Object?>>(json, key))
    if (item is Map<String, Object?>)
      item
    else
      throw FormatException('`$key`: obyektlar massivi kutilgan', item),
];

Json asObject(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw FormatException('obyekt kutilgan', value);
}
