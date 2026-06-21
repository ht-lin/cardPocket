import 'package:flutter_test/flutter_test.dart';

import 'package:card_pocket/features/cards/domain/card_model.dart';

CardModel _card({DateTime? expiresAt}) => CardModel(
      id: 'card-1',
      name: 'Costco',
      barcodeType: 'QR_CODE',
      barcodeContent: '12345',
      isOwner: true,
      expiresAt: expiresAt,
      updatedAt: DateTime(2026, 6, 1),
    );

void main() {
  group('CardModel.isExpired', () {
    test('is false when expiresAt is null', () {
      expect(_card().isExpired, false);
    });

    test('is true when expiresAt is in the past', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(_card(expiresAt: past).isExpired, true);
    });

    test('is false when expiresAt is in the future', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(_card(expiresAt: future).isExpired, false);
    });
  });
}
