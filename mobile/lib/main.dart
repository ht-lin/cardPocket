// Default entry point for IDE "Run" button — uses dev config.
// For actual builds, use main_dev.dart or main_prod.dart with --flavor flag.
import 'bootstrap.dart';
import 'core/config/app_config.dart';

void main() => bootstrap(AppConfig.dev);
