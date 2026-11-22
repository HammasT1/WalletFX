/// Formats a whole-dollar amount with thousands separators, like `$12,400`.
String formatAmount(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer(value < 0 ? '-\$' : '\$');

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }

  return buffer.toString();
}
