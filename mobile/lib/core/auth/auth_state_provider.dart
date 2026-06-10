import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_state.dart';

part 'auth_state_provider.g.dart';

// Manages the global authentication state. Starts as loading while
// AuthNotifier (FE-AUTH-02) attempts a silent token refresh on app start.
// Overridden by AuthNotifier once that module is implemented.
@Riverpod(keepAlive: true)
AuthState authState(Ref ref) => const AuthState.unauthenticated();
