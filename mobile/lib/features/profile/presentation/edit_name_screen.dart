import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../application/profile_notifier.dart';
import '../data/user_repository.dart';

class EditNameScreen extends ConsumerStatefulWidget {
  const EditNameScreen({super.key});

  @override
  ConsumerState<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends ConsumerState<EditNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).value;
    if (user != null) _controller.text = user.userName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _fieldError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateUsername(_controller.text.trim());
      ref.invalidate(profileProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUsernameUpdated),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    } on UnprocessableException catch (e) {
      setState(() {
        _fieldError = e.errors['userName']?.firstOrNull;
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
      appBar: AppBar(title: Text(l10n.profileEditNameTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: l10n.profileNewUsernameLabel,
                  errorText: _fieldError,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.usernameValidationEmpty;
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
