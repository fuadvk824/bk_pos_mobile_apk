import 'package:intl/intl.dart';

final NumberFormat _rupiahFormatter = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(num value) {
  return _rupiahFormatter.format(value);
}

double parseRupiah(String value) {
  final raw = value.replaceAll(RegExp(r'[^0-9]'), '');

  if (raw.isEmpty) return 0;

  return double.tryParse(raw) ?? 0;
}
