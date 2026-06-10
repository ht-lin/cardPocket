import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/application/auth_notifier.dart';
import 'auth_state.dart';

part 'auth_state_provider.g.dart';

// Derives the current AuthState from AuthNotifier.
// Returns AuthState.loading() while the notifier is initialising (silent refresh).
@Riverpod(keepAlive: true)
AuthState authState(Ref ref) =>
    ref.watch(authProvider).value ?? const AuthState.loading();
