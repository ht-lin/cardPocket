import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'barcode_image_analyzer.g.dart';

/// A barcode decoded from an image, ready to prefill the create-card flow.
class BarcodeScanResult {
  const BarcodeScanResult({
    required this.barcodeContent,
    required this.barcodeType,
  });

  final String barcodeContent;
  final String barcodeType;
}

/// Maps a [BarcodeFormat] from mobile_scanner to the backend's `barcodeType`.
String barcodeFormatToApiType(BarcodeFormat format) {
  return switch (format) {
    BarcodeFormat.qrCode => 'QR_CODE',
    BarcodeFormat.code128 => 'CODE_128',
    BarcodeFormat.ean13 => 'EAN_13',
    BarcodeFormat.ean8 => 'EAN_8',
    BarcodeFormat.code39 => 'CODE_39',
    BarcodeFormat.upcA => 'UPC_A',
    BarcodeFormat.upcE => 'UPC_E',
    BarcodeFormat.pdf417 => 'PDF_417',
    BarcodeFormat.dataMatrix => 'DATA_MATRIX',
    BarcodeFormat.aztec => 'AZTEC',
    _ => 'QR_CODE',
  };
}

/// Decodes a barcode/QR from an image file (US-22 gallery import, US-23 share).
class BarcodeImageAnalyzer {
  const BarcodeImageAnalyzer();

  /// Returns the first decoded barcode, or null if the image has none.
  Future<BarcodeScanResult?> analyze(String path) async {
    final controller = MobileScannerController();
    try {
      final capture = await controller.analyzeImage(path);
      final barcode = capture?.barcodes.firstOrNull;
      final value = barcode?.rawValue;
      if (value == null || value.isEmpty) return null;
      return BarcodeScanResult(
        barcodeContent: value,
        barcodeType: barcodeFormatToApiType(barcode!.format),
      );
    } finally {
      await controller.dispose();
    }
  }
}

@Riverpod(keepAlive: true)
BarcodeImageAnalyzer barcodeImageAnalyzer(Ref ref) =>
    const BarcodeImageAnalyzer();

@Riverpod(keepAlive: true)
ImagePicker imagePicker(Ref ref) => ImagePicker();
