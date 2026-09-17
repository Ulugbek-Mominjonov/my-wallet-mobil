import '../calc/delta_calc.dart';
import '../calc/month_attribution.dart';
import '../entities/entity_support.dart';
import '../entities/income.dart';
import '../entities/settings.dart';
import '../repositories/clock.dart';
import '../repositories/id_generator.dart';
import '../repositories/write_command.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import 'validation.dart';

/// Yangi daromad qo'shadi.
///
/// Tegishli oy QOIDADAN hisoblanadi (§2.1) va yozuv bilan birga saqlanadi —
/// keyin ro'yxat faqat `monthKey` bo'yicha so'raladi.
final class AddIncome {
  const AddIncome({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;

  Future<Income> call({
    required Money amount,
    required String type,
    required PaymentMethod method,
    required DateTime paidAt,
    required IncomeRules rules,
    String note = '',
    String? debtId,
  }) async {
    final now = _clock.now();
    final income = Income(
      id: _ids.next(),
      amount: Validate.positiveAmount(amount, 'summa'),
      type: Validate.text(type, 'tur'),
      method: method,
      paidAt: paidAt,
      monthKey: MonthAttribution.forIncome(
        paidAt: paidAt,
        type: type,
        rules: rules,
      ),
      note: note.trim(),
      debtId: Validate.optionalText(debtId),
      createdAt: now,
      updatedAt: now,
    );

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertIncome(income)],
        delta: AggregateDelta.forIncome(after: income),
      ),
    );
    return income;
  }
}

/// Daromadni tahrirlaydi.
///
/// Delta `hissa(after) − hissa(before)` sifatida hisoblanadi, shuning uchun
/// summa, usul, tur yoki OY o'zgarsa ham agregat o'zi to'g'rilanadi —
/// oy o'zgarsa ikkala oy hujjati bitta batchda yangilanadi.
final class EditIncome {
  const EditIncome({required BudgetWriter writer, required Clock clock})
      : _writer = writer,
        _clock = clock;

  final BudgetWriter _writer;
  final Clock _clock;

  Future<Income> call({
    required Income before,
    required IncomeRules rules,
    Money? amount,
    String? type,
    PaymentMethod? method,
    DateTime? paidAt,
    String? note,
    Object? debtId = unchanged,
  }) async {
    final nextType = type == null ? before.type : Validate.text(type, 'tur');
    final nextPaidAt = paidAt ?? before.paidAt;
    final after = before.copyWith(
      amount: amount == null
          ? null
          : Validate.positiveAmount(amount, 'summa'),
      type: nextType,
      method: method,
      paidAt: nextPaidAt,
      monthKey: MonthAttribution.forIncome(
        paidAt: nextPaidAt,
        type: nextType,
        rules: rules,
      ),
      note: note?.trim(),
      debtId: debtId,
      updatedAt: _clock.now(),
    );

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertIncome(after)],
        delta: AggregateDelta.forIncome(before: before, after: after),
      ),
    );
    return after;
  }
}

/// Daromadni o'chiradi (agregatdan ham ayiriladi).
final class RemoveIncome {
  const RemoveIncome(this._writer);

  final BudgetWriter _writer;

  Future<void> call(Income income) => _writer.commit(
        WriteCommand(
          mutations: <DocMutation>[DeleteIncome(income.id)],
          delta: AggregateDelta.forIncome(before: income),
        ),
      );
}
