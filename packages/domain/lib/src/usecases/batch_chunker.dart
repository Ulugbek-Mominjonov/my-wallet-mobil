import '../calc/delta_calc.dart';
import '../repositories/write_command.dart';

/// Bitta yozuv va uning agregatga ta'siri.
typedef MutationWithDelta = ({DocMutation mutation, AggregateDelta delta});

/// Ko'p yozuvli operatsiyalarni Firestore batch chegarasiga bo'ladi.
///
/// Firestore'da bitta `WriteBatch` ≤ 500 amal. Agregat hujjatlar ham shu
/// hisobga kiradi, shuning uchun zaxira bilan 400 da kesiladi (§5.4).
abstract final class BatchChunker {
  static const int maxOperations = 400;

  static List<WriteCommand> split(
    Iterable<MutationWithDelta> items, {
    int maxOperations = BatchChunker.maxOperations,
  }) {
    final commands = <WriteCommand>[];
    var mutations = <DocMutation>[];
    var delta = AggregateDelta.zero;

    void flush() {
      if (mutations.isEmpty && delta.isEmpty) return;
      commands.add(WriteCommand(mutations: mutations, delta: delta));
      mutations = <DocMutation>[];
      delta = AggregateDelta.zero;
    }

    for (final item in items) {
      final nextMutations = mutations.length + 1;
      final nextDelta = delta + item.delta;
      if (nextMutations + nextDelta.documentCount > maxOperations &&
          mutations.isNotEmpty) {
        flush();
      }
      mutations.add(item.mutation);
      delta = delta + item.delta;
    }
    flush();
    return commands;
  }
}
