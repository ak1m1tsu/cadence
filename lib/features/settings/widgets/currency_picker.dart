import 'package:flutter/material.dart';

const List<(String, String)> kCommonCurrencies = [
  ('USD', 'US Dollar'),
  ('EUR', 'Euro'),
  ('GBP', 'British Pound'),
  ('JPY', 'Japanese Yen'),
  ('CAD', 'Canadian Dollar'),
  ('AUD', 'Australian Dollar'),
  ('CHF', 'Swiss Franc'),
  ('CNY', 'Chinese Yuan'),
  ('INR', 'Indian Rupee'),
  ('KRW', 'South Korean Won'),
  ('BRL', 'Brazilian Real'),
  ('MXN', 'Mexican Peso'),
  ('SGD', 'Singapore Dollar'),
  ('HKD', 'Hong Kong Dollar'),
  ('NOK', 'Norwegian Krone'),
  ('SEK', 'Swedish Krona'),
  ('DKK', 'Danish Krone'),
  ('NZD', 'New Zealand Dollar'),
  ('ZAR', 'South African Rand'),
  ('TRY', 'Turkish Lira'),
  ('AED', 'UAE Dirham'),
  ('SAR', 'Saudi Riyal'),
  ('PLN', 'Polish Zloty'),
  ('CZK', 'Czech Koruna'),
  ('HUF', 'Hungarian Forint'),
  ('ILS', 'Israeli Shekel'),
  ('THB', 'Thai Baht'),
  ('MYR', 'Malaysian Ringgit'),
  ('IDR', 'Indonesian Rupiah'),
  ('RUB', 'Russian Ruble'),
];

Future<String?> showCurrencyPicker(
  BuildContext context, {
  required String current,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _CurrencyPickerDialog(current: current),
  );
}

class _CurrencyPickerDialog extends StatefulWidget {
  final String current;

  const _CurrencyPickerDialog({required this.current});

  @override
  State<_CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<_CurrencyPickerDialog> {
  late String _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kCommonCurrencies
        .where((c) =>
            c.$1.toLowerCase().contains(_query.toLowerCase()) ||
            c.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return AlertDialog(
      title: const Text('Select Currency'),
      content: SizedBox(
        width: 320,
        height: 420,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RadioGroup<String>(
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final (code, name) = filtered[i];
                    return ListTile(
                      leading: Radio<String>(value: code),
                      title: Text(code),
                      subtitle: Text(name),
                      dense: true,
                      onTap: () => setState(() => _selected = code),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
