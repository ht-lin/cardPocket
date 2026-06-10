import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connectivity/is_offline_provider.dart';
import '../l10n/l10n_extension.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    return Column(
      children: [
        if (isOffline)
          Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  context.l10n.offlineMode,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
