// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// US-23: handles images shared into CardPocket from other apps. Decodes the
/// barcode and routes to the confirm screen (or manual entry on a miss).
/// Activated by watching it from `app.dart`.

@ProviderFor(SharingImportController)
final sharingImportControllerProvider = SharingImportControllerProvider._();

/// US-23: handles images shared into CardPocket from other apps. Decodes the
/// barcode and routes to the confirm screen (or manual entry on a miss).
/// Activated by watching it from `app.dart`.
final class SharingImportControllerProvider
    extends $AsyncNotifierProvider<SharingImportController, void> {
  /// US-23: handles images shared into CardPocket from other apps. Decodes the
  /// barcode and routes to the confirm screen (or manual entry on a miss).
  /// Activated by watching it from `app.dart`.
  SharingImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingImportControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingImportControllerHash();

  @$internal
  @override
  SharingImportController create() => SharingImportController();
}

String _$sharingImportControllerHash() =>
    r'6e0867f08fb2023d461b7f420754d00c4c314851';

/// US-23: handles images shared into CardPocket from other apps. Decodes the
/// barcode and routes to the confirm screen (or manual entry on a miss).
/// Activated by watching it from `app.dart`.

abstract class _$SharingImportController extends $AsyncNotifier<void> {
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
