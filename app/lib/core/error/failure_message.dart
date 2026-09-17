import 'package:domain/domain.dart';

/// Xatoni foydalanuvchi tilidagi xabarga aylantiradi.
///
/// Xato HECH QACHON yutib yuborilmaydi: domen xatosi tushunarli matnga,
/// kutilmagan xato esa umumiy matnga aylanadi, lekin logga to'liq yoziladi.
String failureMessage(Object error) => switch (error) {
      ValidationFailure(:final message) => message,
      MonthClosedFailure(:final message) => message,
      NotFoundFailure() => "Yozuv topilmadi — ro'yxat yangilandi",
      ConflictFailure(:final message) => message,
      _ => "Nimadir xato ketdi. Qaytadan urinib ko'ring.",
    };
