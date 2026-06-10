import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/auth_state_provider.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../data/auth_repository.dart';

class VerifyPendingScreen extends ConsumerStatefulWidget {
  const VerifyPendingScreen({super.key});

  @override
  ConsumerState<VerifyPendingScreen> createState() =>
      _VerifyPendingScreenState();
}

class _VerifyPendingScreenState extends ConsumerState<VerifyPendingScreen> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyPendingTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 72),
            const SizedBox(height: 24),
            Text(
              l10n.verifyPendingTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.verifyPendingBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSending ? null : _resend,
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.resendVerificationButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resend() async {
    // userId == email when user_id_claim is set to email in Symfony JWT config.
    final authState = ref.read(authStateProvider);
    final email = authState.mapOrNull(unverified: (s) => s.userId) ?? '';
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
        ServerException() => context.l10n.errorServerError,
        _ => error.toString(),
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
