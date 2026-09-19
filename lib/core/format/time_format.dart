import 'package:intl/intl.dart';

/// Hodisa vaqti (qurilma vaqt zonasida): bugun — `14:05`, aks holda
/// `05.10 14:05`.
String formatEventTime(DateTime moment, {DateTime? now}) {
  final local = moment.toLocal();
  final today = (now ?? DateTime.now()).toLocal();
  final sameDay =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  return DateFormat(sameDay ? 'HH:mm' : 'dd.MM HH:mm').format(local);
}
