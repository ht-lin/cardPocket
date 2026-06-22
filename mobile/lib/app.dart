import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/l10n/l10n_extension.dart';
import 'core/router/router_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'features/auth/presentation/widgets/unverified_banner.dart';
import 'features/cards/application/owned_cards_notifier.dart';
import 'features/cards/application/viewed_cards_notifier.dart';
import 'features/notifications/application/push_notification_controller.dart';

class App extends ConsumerStatefulWidget {
  const App({required this.config, super.key});
  final AppConfig config;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(ownedCardsProvider);
      ref.invalidate(viewedCardsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);
    // Activate FCM wiring (permission, token registration, deep links).
    // No-op until Firebase initialised and the user is authenticated.
    ref.watch(pushNotificationControllerProvider);
    return MaterialApp.router(
      title: 'CardPocket',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => OfflineBanner(
        child: Column(
          children: [
            const UnverifiedBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
