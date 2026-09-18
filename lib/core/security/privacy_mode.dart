import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BR-212: maxfiylik rejimi — barcha summalar `•••` bilan yashiriladi.
/// Holatni saqlash va tugma E14-T05 da.
final privacyModeProvider = NotifierProvider<PrivacyMode, bool>(
  PrivacyMode.new,
);

final class PrivacyMode extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
