// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shareRepository)
final shareRepositoryProvider = ShareRepositoryProvider._();

final class ShareRepositoryProvider
    extends
        $FunctionalProvider<ShareRepository, ShareRepository, ShareRepository>
    with $Provider<ShareRepository> {
  ShareRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShareRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareRepository create(Ref ref) {
    return shareRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareRepository>(value),
    );
  }
}

String _$shareRepositoryHash() => r'f2816e5ea68876380fed1e34c80319d18b2a703d';
