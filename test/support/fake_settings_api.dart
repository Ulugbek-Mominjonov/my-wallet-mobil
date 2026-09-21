import 'package:my_wallet/data/remote/settings_api.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// Server sozlamalari o'rnida: javoblar testdan, chaqiruvlar yoziladi.
final class FakeSettingsApi implements SettingsApi {
  Result<NotificationPrefs> prefs = const Ok(NotificationPrefs());
  Result<void> saveResult = const Ok(null);
  bool linked = false;
  Result<List<ChannelResult>> testResult = const Ok([]);
  Result<int> deleteResult = const Ok(1);

  final saved = <NotificationPrefs>[];
  int deleteCalls = 0;
  int unlinkCalls = 0;

  @override
  Future<Result<NotificationPrefs>> notificationPrefs(
    String householdId,
  ) async => prefs;

  @override
  Future<Result<void>> saveNotificationPrefs(
    String householdId,
    NotificationPrefs prefs,
  ) async {
    saved.add(prefs);
    return saveResult;
  }

  @override
  Future<Result<bool>> telegramLinked() async => Ok(linked);

  @override
  Future<Result<void>> telegramUnlink() async {
    unlinkCalls++;
    linked = false;
    return const Ok(null);
  }

  @override
  Future<Result<List<ChannelResult>>> testNotification(
    String householdId,
  ) async => testResult;

  @override
  Future<Result<int>> deleteAccount() async {
    deleteCalls++;
    return deleteResult;
  }
}
