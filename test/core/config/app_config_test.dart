import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/config/app_config.dart';

void main() {
  test("env fayli berilmagan build aniq xato beradi (prod'da noto'g'ri backend "
      "bo'lib qolmasin)", () {
    expect(
      () => AppConfig.fromEnvironment(expected: AppEnv.prod),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('env/prod.json'),
        ),
      ),
    );
  });
}
