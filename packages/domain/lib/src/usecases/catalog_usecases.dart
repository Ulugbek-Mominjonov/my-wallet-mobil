import '../entities/catalog.dart';
import '../entities/settings.dart';
import '../repositories/id_generator.dart';
import '../repositories/write_command.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import 'validation.dart';

/// Doimiy xarajat shablonini saqlaydi.
final class SaveRecurring {
  const SaveRecurring({
    required BudgetWriter writer,
    required IdGenerator ids,
  })  : _writer = writer,
        _ids = ids;

  final BudgetWriter _writer;
  final IdGenerator _ids;

  Future<RecurringExpense> call({
    required String name,
    required String category,
    required PaymentMethod method,
    required int day,
    RecurringExpense? existing,
    Money? amount,
    bool autoPay = false,
    bool active = true,
    String? debtId,
    int order = 0,
  }) async {
    final item = RecurringExpense(
      id: existing?.id ?? _ids.next(),
      name: Validate.text(name, 'nom'),
      category: Validate.text(category, 'kategoriya'),
      method: method,
      day: Validate.day(day, 'kun'),
      amount: amount == null ? null : Validate.amount(amount, 'summa'),
      autoPay: autoPay,
      active: active,
      debtId: Validate.optionalText(debtId),
      order: order,
    );
    await _writer.commit(
      WriteCommand(mutations: <DocMutation>[UpsertRecurring(item)]),
    );
    return item;
  }
}

/// Kategoriya limitini saqlaydi.
final class SaveLimit {
  const SaveLimit({required BudgetWriter writer, required IdGenerator ids})
      : _writer = writer,
        _ids = ids;

  final BudgetWriter _writer;
  final IdGenerator _ids;

  Future<CategoryLimit> call({
    required String category,
    required Money monthlyLimit,
    CategoryLimit? existing,
  }) async {
    final item = CategoryLimit(
      id: existing?.id ?? _ids.next(),
      category: Validate.text(category, 'kategoriya'),
      monthlyLimit: Validate.positiveAmount(monthlyLimit, 'limit'),
    );
    await _writer.commit(
      WriteCommand(mutations: <DocMutation>[UpsertLimit(item)]),
    );
    return item;
  }
}

/// Tez qo'shish tugmasini saqlaydi.
final class SaveQuickAdd {
  const SaveQuickAdd({required BudgetWriter writer, required IdGenerator ids})
      : _writer = writer,
        _ids = ids;

  final BudgetWriter _writer;
  final IdGenerator _ids;

  Future<QuickAdd> call({
    required String name,
    required Money amount,
    required String category,
    required PaymentMethod method,
    QuickAdd? existing,
    int order = 0,
  }) async {
    final item = QuickAdd(
      id: existing?.id ?? _ids.next(),
      name: Validate.text(name, 'nom'),
      amount: Validate.positiveAmount(amount, 'summa'),
      category: Validate.text(category, 'kategoriya'),
      method: method,
      order: order,
    );
    await _writer.commit(
      WriteCommand(mutations: <DocMutation>[UpsertQuickAdd(item)]),
    );
    return item;
  }
}

/// Katalog yozuvini o'chiradi.
final class RemoveCatalogItem {
  const RemoveCatalogItem(this._writer);

  final BudgetWriter _writer;

  Future<void> recurring(String id) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[DeleteRecurring(id)]),
      );

  Future<void> limit(String id) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[DeleteLimit(id)]),
      );

  Future<void> quickAdd(String id) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[DeleteQuickAdd(id)]),
      );
}

/// Sozlamalarni saqlaydi (4 ta hujjat bitta batchda).
final class SaveBudgetSettings {
  const SaveBudgetSettings(this._writer);

  final BudgetWriter _writer;

  Future<void> call(BudgetSettings settings) => _writer.commit(
        WriteCommand(mutations: <DocMutation>[SaveSettings(settings)]),
      );
}
