import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../data/cards_repository.dart';
import '../domain/card_model.dart';

class BarcodeScreen extends ConsumerStatefulWidget {
  const BarcodeScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
  CardModel? _card;

  @override
  void initState() {
    super.initState();
    ScreenBrightness().setApplicationScreenBrightness(1.0);
    ref.read(cardsRepositoryProvider).getCardById(widget.id).then((card) {
      if (mounted) setState(() => _card = card);
    });
  }

  @override
  void dispose() {
    ScreenBrightness().resetApplicationScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;

    String title;
    if (card == null) {
      title = 'Card';
    } else if (!card.isOwner) {
      final nick = card.viewerNickname;
      final owner = card.ownerUsername ?? '';
      title = nick != null ? '$nick($owner)' : '${card.name}($owner)';
    } else {
      title = card.name;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: card == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: bw.BarcodeWidget(
                  barcode: _toBarcodeWidget(card.barcodeType),
                  data: card.barcodeContent,
                  color: Colors.white,
                  drawText: true,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
    );
  }

  bw.Barcode _toBarcodeWidget(String type) {
    return switch (type) {
      'QR_CODE' => bw.Barcode.qrCode(),
      'CODE_128' => bw.Barcode.code128(),
      'EAN_13' => bw.Barcode.ean13(),
      'EAN_8' => bw.Barcode.ean8(),
      'CODE_39' => bw.Barcode.code39(),
      'UPC_A' => bw.Barcode.upcA(),
      'UPC_E' => bw.Barcode.upcE(),
      'PDF_417' => bw.Barcode.pdf417(),
      'DATA_MATRIX' => bw.Barcode.dataMatrix(),
      _ => bw.Barcode.qrCode(),
    };
  }
}
