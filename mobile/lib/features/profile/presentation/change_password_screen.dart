import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../data/user_repository.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _currentPasswordError;
  String? _newPasswordError;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userRepositoryProvider).updatePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profilePasswordUpdated),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    } on UnprocessableException catch (e) {
      setState(() {
        _currentPasswordError =
            e.errors['currentPassword']?.firstOrNull;
        _newPasswordError = e.errors['newPassword']?.firstOrNull;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        NetworkException() => context.l10n.errorNetworkTimeout,
        _ => context.l10n.errorServerError,
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileChangePasswordTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _currentController,
                decoration: InputDecoration(
                  labelText: l10n.profileCurrentPasswordLabel,
                  errorText: _currentPasswordError,
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return l10n.passwordValidationEmpty;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                decoration: InputDecoration(
                  labelText: l10n.profileNewPasswordLabel,
                  errorText: _newPasswordError,
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return l10n.passwordValidationEmpty;
                  }
                  if (v.length < 8) return l10n.passwordValidationTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: l10n.profileConfirmPasswordLabel,
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) {
                  if (v != _newController.text) {
                    return l10n.profilePasswordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.profileSaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
