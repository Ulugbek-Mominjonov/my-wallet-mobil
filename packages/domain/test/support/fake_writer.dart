import 'package:domain/domain.dart';

/// Yozuv portining test dublyori.
///
/// Haqiqiy Firestore o'rniga barcha `WriteCommand` larni yig'ib qo'yadi —
/// shunda "40 ta to'lov = 1 batch" kabi talablarni tekshirish mumkin.
final class FakeWriter implements BudgetWriter {
  final List<WriteCommand> commands = <WriteCommand>[];

  /// Nechta batch yuborildi.
  int get batchCount => commands.length;

  WriteCommand get last => commands.last;

  AggregateDelta get mergedDelta =>
      AggregateDelta.merge(commands.map((command) => command.delta));

  List<DocMutation> get mutations =>
      commands.expand((command) => command.mutations).toList();

  @override
  Future<void> commit(WriteCommand command) async {
    commands.add(command);
  }
}

/// Ketma-ket ID beruvchi.
final class SeqIds implements IdGenerator {
  SeqIds([this._prefix = 'id']);

  final String _prefix;
  int _counter = 0;

  @override
  String next() => '$_prefix${++_counter}';
}
