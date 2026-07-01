import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_logo.dart';
import '../application/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) => _handleError(error),
      );
    });

    final isLoading = ref.watch(authProvider).isLoading;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
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
                  errorText: _emailError,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.emailValidationEmpty;
                  }
                  if (!v.contains('@')) return l10n.emailValidationInvalid;
                  return null;
                },
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.loginPasswordLabel,
                  errorText: _passwordError,
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
                  return null;
                },
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.loginSubmitButton),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.goNamed(RouteNames.register),
                child: Text(l10n.loginRegisterLink),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  void _handleError(Object error) {
    if (error is UnprocessableException) {
      setState(() {
        _emailError = error.errors['email']?.firstOrNull;
        _passwordError = error.errors['password']?.firstOrNull;
      });
      return;
    }
    final message = switch (error) {
      UnauthorizedException() => context.l10n.errorInvalidCredentials,
      NetworkException() => context.l10n.errorNetworkTimeout,
      ServerException() => context.l10n.errorServerError,
      _ => error.toString(),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
