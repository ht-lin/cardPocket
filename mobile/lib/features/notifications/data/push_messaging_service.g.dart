// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_messaging_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushMessagingService)
final pushMessagingServiceProvider = PushMessagingServiceProvider._();

final class PushMessagingServiceProvider
    extends
        $FunctionalProvider<
          PushMessagingService,
          PushMessagingService,
          PushMessagingService
        >
    with $Provider<PushMessagingService> {
  PushMessagingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushMessagingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushMessagingServiceHash();

  @$internal
  @override
  $ProviderElement<PushMessagingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushMessagingService create(Ref ref) {
    return pushMessagingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushMessagingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushMessagingService>(value),
    );
  }
}

String _$pushMessagingServiceHash() =>
    r'bf7670b806b9282aec239f903117d5fdc3d34001';
