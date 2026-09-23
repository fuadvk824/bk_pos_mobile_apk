import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final NumberFormat _rupiahInputFormatter = NumberFormat('#,##0', 'id_ID');

String formatRupiah(num value) {
  return _rupiahFormatter.format(value);
}

String formatRupiahInput(num value) {
  return _rupiahInputFormatter.format(value);
}

double parseRupiah(String value) {
  final raw = value.replaceAll(RegExp(r'[^0-9]'), '');

  if (raw.isEmpty) {
    return 0;
  }

  return double.tryParse(raw) ?? 0;
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    final number = int.tryParse(digits) ?? 0;

    final formatted = _rupiahInputFormatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
