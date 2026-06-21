import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../data/cards_repository.dart';
import '../domain/card_model.dart';
import 'widgets/color_field.dart';

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
      appBar: AppBar(title: Text(title)),
      body: card == null
          ? const Center(child: CircularProgressIndicator())
          : _CardPanel(card: card, barcode: _toBarcodeWidget(card.barcodeType)),
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

/// A rounded color card sitting near the top of the screen, framed by
/// whitespace. The custom color (or theme default) is the card background; the
/// barcode itself renders black on an inner white panel so it stays scannable
/// regardless of the chosen color.
class _CardPanel extends StatelessWidget {
  const _CardPanel({required this.card, required this.barcode});

  final CardModel card;
  final bw.Barcode barcode;

  @override
  Widget build(BuildContext context) {
    final cardColor = colorFromHex(card.color) ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final onCardColor =
        ThemeData.estimateBrightnessForColor(cardColor) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card.isExpired) ...[
                const Text(
                  'Expired',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: bw.BarcodeWidget(
                  barcode: barcode,
                  data: card.barcodeContent,
                  color: Colors.black,
                  drawText: false,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.barcodeContent,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onCardColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
