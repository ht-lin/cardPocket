import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_pocket/features/cards/presentation/widgets/color_field.dart';

void main() {
  group('colorFromHex', () {
    test('parses a valid #RRGGBB string into an opaque color', () {
      final color = colorFromHex('#FF5733');
      expect(color, isNotNull);
      expect(hexFromColor(color!), '#FF5733');
      expect((color.a * 255).round(), 255);
    });

    test('is case-insensitive', () {
      expect(colorFromHex('#ff5733'), colorFromHex('#FF5733'));
    });

    test('returns null for null input', () {
      expect(colorFromHex(null), isNull);
    });

    test('returns null for malformed input', () {
      expect(colorFromHex('FF5733'), isNull); // missing #
      expect(colorFromHex('#FFF'), isNull); // too short
      expect(colorFromHex('#GGGGGG'), isNull); // non-hex
      expect(colorFromHex(''), isNull);
    });
  });

  group('hexFromColor', () {
    test('serializes to uppercase #RRGGBB, dropping alpha', () {
      expect(hexFromColor(const Color(0x8000FF00)), '#00FF00');
    });

    test('round-trips with colorFromHex', () {
      for (final hex in ['#000000', '#FFFFFF', '#123ABC', '#FF5733']) {
        expect(hexFromColor(colorFromHex(hex)!), hex);
      }
    });
  });
}
