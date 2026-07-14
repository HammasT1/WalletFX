String formatCardNumber(String value) {
  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
  final buffer = StringBuffer();

  for (var index = 0; index < digitsOnly.length; index++) {
    if (index > 0 && index % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(digitsOnly[index]);
  }

  return buffer.toString();
}
