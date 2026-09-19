import 'package:my_wallet/bootstrap.dart';
import 'package:my_wallet/core/config/app_config.dart';

Future<void> main() => bootstrap(env: AppEnv.prod);
