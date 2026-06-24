import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:card_pocket/features/cards/data/barcode_image_analyzer.dart';

void main() {
  group('barcodeFormatToApiType', () {
    test('maps known formats to backend barcodeType values', () {
      expect(barcodeFormatToApiType(BarcodeFormat.qrCode), 'QR_CODE');
      expect(barcodeFormatToApiType(BarcodeFormat.code128), 'CODE_128');
      expect(barcodeFormatToApiType(BarcodeFormat.ean13), 'EAN_13');
      expect(barcodeFormatToApiType(BarcodeFormat.ean8), 'EAN_8');
      expect(barcodeFormatToApiType(BarcodeFormat.code39), 'CODE_39');
      expect(barcodeFormatToApiType(BarcodeFormat.upcA), 'UPC_A');
      expect(barcodeFormatToApiType(BarcodeFormat.upcE), 'UPC_E');
      expect(barcodeFormatToApiType(BarcodeFormat.pdf417), 'PDF_417');
      expect(barcodeFormatToApiType(BarcodeFormat.dataMatrix), 'DATA_MATRIX');
      expect(barcodeFormatToApiType(BarcodeFormat.aztec), 'AZTEC');
    });

    test('falls back to QR_CODE for unknown formats', () {
      expect(barcodeFormatToApiType(BarcodeFormat.unknown), 'QR_CODE');
    });
  });
}
