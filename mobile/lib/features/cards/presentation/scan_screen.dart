import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/route_names.dart';
import '../data/barcode_image_analyzer.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
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
              _openConfirm(value, barcodeFormatToApiType(barcode!.format));
            },
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Pick from gallery'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.pushNamed(RouteNames.cardsCreate),
                  child: const Text('Manual input'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openConfirm(String barcodeContent, String barcodeType) {
    context.pushNamed(
      RouteNames.cardsScanConfirm,
      extra: {'barcodeContent': barcodeContent, 'barcodeType': barcodeType},
    );
  }

  Future<void> _pickFromGallery() async {
    if (_detected) return;
    final picked = await ref
        .read(imagePickerProvider)
        .pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final result = await ref.read(barcodeImageAnalyzerProvider).analyze(picked.path);
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barcode found in the image')),
      );
      return;
    }
    _detected = true;
    _openConfirm(result.barcodeContent, result.barcodeType);
  }
}
