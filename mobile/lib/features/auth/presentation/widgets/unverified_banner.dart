import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/auth_state_provider.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../data/auth_repository.dart';

class UnverifiedBanner extends ConsumerStatefulWidget {
  const UnverifiedBanner({super.key});

  @override
  ConsumerState<UnverifiedBanner> createState() => _UnverifiedBannerState();
}

class _UnverifiedBannerState extends ConsumerState<UnverifiedBanner> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    if (authState is! Unverified) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialBanner(
      backgroundColor: colorScheme.secondaryContainer,
      content: Text(
        l10n.unverifiedBannerMessage,
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => _resend(authState.userId),
          child: Text(l10n.unverifiedBannerAction),
        ),
      ],
    );
  }

  Future<void> _resend(String email) async {
    if (email.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ref.read(authRepositoryProvider).resendVerification(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.resendVerificationSuccess)),
      );
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        NetworkException() => context.l10n.errorNetworkTimeout,
        _ => context.l10n.errorServerError,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
