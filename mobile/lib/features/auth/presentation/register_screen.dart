import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_logo.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _gdprConsent = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Center(child: AppLogo(size: 96)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.loginEmailLabel,
                  errorText: _fieldErrors['email'],
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.emailValidationEmpty;
                  }
                  if (!v.contains('@')) return l10n.emailValidationInvalid;
                  return null;
                },
                onChanged: (_) => _clearFieldError('email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.registerUsernameLabel,
                  errorText: _fieldErrors['userName'],
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.usernameValidationEmpty;
                  }
                  return null;
                },
                onChanged: (_) => _clearFieldError('userName'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.loginPasswordLabel,
                  errorText: _fieldErrors['password'],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return l10n.passwordValidationEmpty;
                  }
                  if (v.length < 8) return l10n.passwordValidationTooShort;
                  return null;
                },
                onChanged: (_) => _clearFieldError('password'),
              ),
              const SizedBox(height: 16),
              FormField<bool>(
                initialValue: false,
                validator: (v) =>
                    (v ?? false) ? null : l10n.gdprValidationRequired,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _gdprConsent,
                          onChanged: (v) {
                            setState(() => _gdprConsent = v ?? false);
                            field.didChange(v);
                          },
                        ),
                        Expanded(child: Text(l10n.registerGdprLabel)),
                      ],
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.registerSubmitButton),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.goNamed(RouteNames.login),
                child: Text(l10n.registerLoginLink),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors = Map.of(_fieldErrors)..remove(field));
    }
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = {});
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).register(
            RegisterRequest(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              userName: _usernameController.text.trim(),
              gdprConsent: _gdprConsent,
            ),
          );
      if (mounted) context.goNamed(RouteNames.verifyPending);
    } on UnprocessableException catch (e) {
      setState(() {
        _fieldErrors = e.errors.map((k, v) => MapEntry(k, v.first));
      });
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
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
