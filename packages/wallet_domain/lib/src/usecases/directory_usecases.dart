import 'package:wallet_domain/src/entities/category.dart';
import 'package:wallet_domain/src/entities/enums.dart';
import 'package:wallet_domain/src/failures.dart';
import 'package:wallet_domain/src/result.dart';
import 'package:wallet_domain/src/usecases/deps.dart';

// Spravochniklar — serverdagi cheklovlar bilan bir xil (contracts/api.md:
// nom 1–60 belgi, byudjet ichida registrsiz yagona — BR-003).

/// Nom uzunligi chegarasi (`entity_name` domeni).
const maxEntityNameLength = 60;

/// BR-003: nomlarni solishtirish kaliti.
String normalizeName(String name) => name.trim().toLowerCase();

/// BR-035: amal qo'shayotganda joyida yangi kategoriya. Shu nomli (shu
/// turdagi) kategoriya bor bo'lsa — o'sha qaytariladi (ikkinchisi
/// yaratilmaydi).
final class CreateCategory {
  const new(this._deps);

  final DomainDeps _deps;

  Future<Result<Category>> call({
    required CategoryKind kind,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxEntityNameLength) {
      return const Err(ValidationFailure('name', 'invalid_name'));
    }
    final existing = await _deps.categories.byName(kind, trimmed);
    if (existing != null) return Ok(existing);

    final household = await _deps.households.current();
    final category = Category(
      id: _deps.ids.newId(),
      householdId: household.id,
      kind: kind,
      name: trimmed,
      // Yangi kategoriya ro'yxat oxirida (tartibni foydalanuvchi o'zgartiradi).
      sortOrder: 1000,
    );
    await _deps.transactor.run(() => _deps.categories.save(category));
    return Ok(category);
  }
}
