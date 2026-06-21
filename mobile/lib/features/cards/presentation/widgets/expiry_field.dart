import 'package:flutter/material.dart';

/// Formats a date as `yyyy-MM-dd` for display, avoiding a direct dependency on
/// `intl` (which is only a transitive dep via flutter_localizations).
String formatExpiryDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// A form row letting the user pick an optional card expiry date and clear it.
class ExpiryField extends StatelessWidget {
  const ExpiryField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Expiry date',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pick(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  value != null ? formatExpiryDate(value) : 'No expiry',
                  style: value != null
                      ? Theme.of(context).textTheme.bodyLarge
                      : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                ),
              ),
            ),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear expiry date',
              onPressed: () => onChanged(null),
            )
          else
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              tooltip: 'Pick expiry date',
              onPressed: () => _pick(context),
            ),
        ],
      ),
    );
  }
}
