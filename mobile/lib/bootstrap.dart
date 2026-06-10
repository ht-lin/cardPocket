import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_config_provider.dart';

Future<void> bootstrap(AppConfig config) async {
  await SentryFlutter.init(
    (options) {
      // Empty DSN disables Sentry (used in dev by default).
      options.dsn = config.sentryDsn;
      options.environment = config.flavorName;
      // Sample 20 % of traces in prod; capture everything in dev.
      options.tracesSampleRate = config.isDevFlavor ? 1.0 : 0.2;
    },
    appRunner: () => runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        // Capture Flutter framework errors (widget build failures, etc.).
        FlutterError.onError = (details) {
          Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
          );
        };

        // Capture platform-channel and root-zone errors (Flutter 3.3+).
        PlatformDispatcher.instance.onError = (error, stack) {
          Sentry.captureException(error, stackTrace: stack);
          return true;
        };

        runApp(
          ProviderScope(
            overrides: [appConfigProvider.overrideWithValue(config)],
            child: App(config: config),
          ),
        );
      },
      // Capture errors thrown inside Futures not connected to the widget tree.
      (error, stack) => Sentry.captureException(error, stackTrace: stack),
    ),
  );
}
