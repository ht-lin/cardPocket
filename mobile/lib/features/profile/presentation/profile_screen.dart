import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/router/route_names.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/domain/auth_models.dart';
import '../application/profile_notifier.dart';
import '../data/user_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorServerError),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(profileProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.profileEditNameTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(RouteNames.profileEditName),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.profileChangePasswordTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.pushNamed(RouteNames.profileChangePassword),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.profileTrashTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(RouteNames.trash),
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.auto_delete_outlined),
              title: Text(l10n.profileExpiryPolicyTitle),
              subtitle: Text(l10n.profileExpiryPolicySubtitle),
              value: user.expiryPolicy == ExpiryPolicy.autoTrash,
              onChanged: (enabled) =>
                  _updateExpiryPolicy(context, ref, enabled),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.profileLogoutButton),
              onTap: () =>
                  ref.read(authProvider.notifier).logout(),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.profileDeleteAccountButton,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateExpiryPolicy(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final policy = enabled ? ExpiryPolicy.autoTrash : ExpiryPolicy.keep;
    try {
      await ref.read(userRepositoryProvider).updateExpiryPolicy(policy);
      ref.invalidate(profileProvider);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final message = switch (e) {
        NetworkException() => context.l10n.errorNetworkTimeout,
        _ => context.l10n.errorServerError,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteAccountConfirmTitle),
        content: Text(l10n.profileDeleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.profileDeleteAccountCancelAction),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.profileDeleteAccountConfirmAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(userRepositoryProvider).deleteAccount();
      await ref.read(appDatabaseProvider).clearAllData();
      await ref.read(authProvider.notifier).logout();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      final message = switch (e) {
        NetworkException() => context.l10n.errorNetworkTimeout,
        _ => context.l10n.errorServerError,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
