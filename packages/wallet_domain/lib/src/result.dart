import 'package:meta/meta.dart';
import 'package:wallet_domain/src/failures.dart';

/// Use-case natijasi: qiymat yoki aniq sabab ([Failure]). Biznes xatolari
/// exception bilan emas — UI har holatni `switch` bilan ko'rib chiqadi.
@immutable
sealed class Result<T> {
  const new();
}

final class Ok<T> extends Result<T> {
  const new(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const new(this.failure);

  final Failure failure;
}
