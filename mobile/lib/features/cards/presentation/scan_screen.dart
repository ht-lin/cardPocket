import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/route_names.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _detected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_detected) return;
              final barcode = capture.barcodes.firstOrNull;
              final value = barcode?.rawValue;
              if (value == null || value.isEmpty) return;
              _detected = true;
              final apiType = _toApiType(barcode!.format);
              context.pushNamed(
                RouteNames.cardsScanConfirm,
                extra: {'barcodeContent': value, 'barcodeType': apiType},
              );
            },
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.tonal(
                onPressed: () => context.pushNamed(RouteNames.cardsCreate),
                child: const Text('Manual input'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toApiType(BarcodeFormat format) {
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
}
