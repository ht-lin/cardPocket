import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Parses a `#RRGGBB` hex string into an opaque [Color]. Returns null for null
/// or malformed input, so callers can fall back to a theme default.
Color? colorFromHex(String? hex) {
  if (hex == null) return null;
  final match = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(hex.trim());
  if (match == null) return null;
  return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
}

/// Serializes a [Color] back to an uppercase `#RRGGBB` string, matching the
/// backend's expected format (alpha is dropped).
String hexFromColor(Color color) {
  int channel(double v) => (v * 255).round().clamp(0, 255);
  String hex(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${hex(channel(color.r))}${hex(channel(color.g))}'
          '${hex(channel(color.b))}'
      .toUpperCase();
}

/// A form row letting the user pick an optional card background color and clear
/// it. Mirrors [ExpiryField]'s shape: `value` is a `#RRGGBB` string or null.
class ColorField extends StatelessWidget {
  const ColorField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  Future<void> _pick(BuildContext context) async {
    var selected = colorFromHex(value) ?? Theme.of(context).colorScheme.primary;
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selected,
            onColorChanged: (c) => selected = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selected),
            child: const Text('Select'),
          ),
        ],
      ),
    );
    if (picked != null) onChanged(hexFromColor(picked));
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(value);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Card color',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pick(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    if (color != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        value!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ] else
                      Text(
                        'No color',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (color != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear color',
              onPressed: () => onChanged(null),
            )
          else
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Pick color',
              onPressed: () => _pick(context),
            ),
        ],
      ),
    );
  }
}
