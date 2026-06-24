// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_image_analyzer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(barcodeImageAnalyzer)
final barcodeImageAnalyzerProvider = BarcodeImageAnalyzerProvider._();

final class BarcodeImageAnalyzerProvider
    extends
        $FunctionalProvider<
          BarcodeImageAnalyzer,
          BarcodeImageAnalyzer,
          BarcodeImageAnalyzer
        >
    with $Provider<BarcodeImageAnalyzer> {
  BarcodeImageAnalyzerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barcodeImageAnalyzerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barcodeImageAnalyzerHash();

  @$internal
  @override
  $ProviderElement<BarcodeImageAnalyzer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BarcodeImageAnalyzer create(Ref ref) {
    return barcodeImageAnalyzer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BarcodeImageAnalyzer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BarcodeImageAnalyzer>(value),
    );
  }
}

String _$barcodeImageAnalyzerHash() =>
    r'2ebd5e95ad65cb694e6761df8ba2c54069c4b696';

@ProviderFor(imagePicker)
final imagePickerProvider = ImagePickerProvider._();

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  ImagePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<ImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'be60667b04027cd2a7d2e1b728a5c03b1bda8dc1';
