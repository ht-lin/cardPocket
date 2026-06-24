// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_intent_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharingIntentService)
final sharingIntentServiceProvider = SharingIntentServiceProvider._();

final class SharingIntentServiceProvider
    extends
        $FunctionalProvider<
          SharingIntentService,
          SharingIntentService,
          SharingIntentService
        >
    with $Provider<SharingIntentService> {
  SharingIntentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingIntentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingIntentServiceHash();

  @$internal
  @override
  $ProviderElement<SharingIntentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharingIntentService create(Ref ref) {
    return sharingIntentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharingIntentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharingIntentService>(value),
    );
  }
}

String _$sharingIntentServiceHash() =>
    r'908fc996d3952fefb8f3bb2c6dbb17ae726a86d4';
