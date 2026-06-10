import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_config.dart';

part 'app_config_provider.g.dart';

// Overridden in bootstrap() with the flavor-specific config.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig.dev;
