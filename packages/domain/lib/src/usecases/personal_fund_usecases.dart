import '../calc/delta_calc.dart';
import '../calc/month_attribution.dart';
import '../entities/personal_spend.dart';
import '../repositories/clock.dart';
import '../repositories/id_generator.dart';
import '../repositories/write_command.dart';
import '../value_objects/enums.dart';
import '../value_objects/money.dart';
import 'validation.dart';

/// 👤 Shaxsiy fonddan sarf qo'shadi.
///
/// Bu yozuv oylik byudjet qoldig'iga TA'SIR QILMAYDI — faqat fond
/// qoldig'ini kamaytiradi va "orttirgan" ko'rsatkichini to'g'rilaydi.
final class AddPersonalSpend {
  const AddPersonalSpend({
    required BudgetWriter writer,
    required Clock clock,
    required IdGenerator ids,
  })  : _writer = writer,
        _clock = clock,
        _ids = ids;

  final BudgetWriter _writer;
  final Clock _clock;
  final IdGenerator _ids;

  Future<PersonalSpend> call({
    required Money amount,
    required String purpose,
    required PaymentMethod method,
    required DateTime spentAt,
    String note = '',
  }) async {
    final now = _clock.now();
    final spend = PersonalSpend(
      id: _ids.next(),
      amount: Validate.positiveAmount(amount, 'summa'),
      purpose: Validate.text(purpose, 'maqsad'),
      method: method,
      spentAt: spentAt,
      monthKey: MonthAttribution.forPersonalSpend(spentAt),
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertPersonalSpend(spend)],
        delta: AggregateDelta.forPersonalSpend(after: spend),
      ),
    );
    return spend;
  }
}

/// Sarfni tahrirlaydi.
final class EditPersonalSpend {
  const EditPersonalSpend({
    required BudgetWriter writer,
    required Clock clock,
  })  : _writer = writer,
        _clock = clock;

  final BudgetWriter _writer;
  final Clock _clock;

  Future<PersonalSpend> call({
    required PersonalSpend before,
    Money? amount,
    String? purpose,
    PaymentMethod? method,
    DateTime? spentAt,
    String? note,
  }) async {
    final nextSpentAt = spentAt ?? before.spentAt;
    final after = before.copyWith(
      amount:
          amount == null ? null : Validate.positiveAmount(amount, 'summa'),
      purpose: purpose == null ? null : Validate.text(purpose, 'maqsad'),
      method: method,
      spentAt: nextSpentAt,
      monthKey: MonthAttribution.forPersonalSpend(nextSpentAt),
      note: note?.trim(),
      updatedAt: _clock.now(),
    );

    await _writer.commit(
      WriteCommand(
        mutations: <DocMutation>[UpsertPersonalSpend(after)],
        delta: AggregateDelta.forPersonalSpend(before: before, after: after),
      ),
    );
    return after;
  }
}

/// Sarfni o'chiradi.
final class RemovePersonalSpend {
  const RemovePersonalSpend(this._writer);

  final BudgetWriter _writer;

  Future<void> call(PersonalSpend spend) => _writer.commit(
        WriteCommand(
          mutations: <DocMutation>[DeletePersonalSpend(spend.id)],
          delta: AggregateDelta.forPersonalSpend(before: spend),
        ),
      );
}
