// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether Firebase initialised successfully at startup. Defaults to false and
/// is overridden to true from `bootstrap.dart` once `Firebase.initializeApp`
/// succeeds, so the app still runs when push credentials are absent (e.g. dev).

@ProviderFor(pushAvailable)
final pushAvailableProvider = PushAvailableProvider._();

/// Whether Firebase initialised successfully at startup. Defaults to false and
/// is overridden to true from `bootstrap.dart` once `Firebase.initializeApp`
/// succeeds, so the app still runs when push credentials are absent (e.g. dev).

final class PushAvailableProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether Firebase initialised successfully at startup. Defaults to false and
  /// is overridden to true from `bootstrap.dart` once `Firebase.initializeApp`
  /// succeeds, so the app still runs when push credentials are absent (e.g. dev).
  PushAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return pushAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pushAvailableHash() => r'fb870d96eedbf245423949aaf4cef3cd1953fb08';

/// Wires FCM into the app: requests permission, registers the token, keeps it
/// fresh, refreshes in-app state on foreground messages, and deep-links on
/// notification taps. Activated by watching it from `app.dart`.

@ProviderFor(PushNotificationController)
final pushNotificationControllerProvider =
    PushNotificationControllerProvider._();

/// Wires FCM into the app: requests permission, registers the token, keeps it
/// fresh, refreshes in-app state on foreground messages, and deep-links on
/// notification taps. Activated by watching it from `app.dart`.
final class PushNotificationControllerProvider
    extends $AsyncNotifierProvider<PushNotificationController, void> {
  /// Wires FCM into the app: requests permission, registers the token, keeps it
  /// fresh, refreshes in-app state on foreground messages, and deep-links on
  /// notification taps. Activated by watching it from `app.dart`.
  PushNotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushNotificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushNotificationControllerHash();

  @$internal
  @override
  PushNotificationController create() => PushNotificationController();
}

String _$pushNotificationControllerHash() =>
    r'25ea7eae484fedb2b65ba610aac17ac4921f0e0c';

/// Wires FCM into the app: requests permission, registers the token, keeps it
/// fresh, refreshes in-app state on foreground messages, and deep-links on
/// notification taps. Activated by watching it from `app.dart`.

abstract class _$PushNotificationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
