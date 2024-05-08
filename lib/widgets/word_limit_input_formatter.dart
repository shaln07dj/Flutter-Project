import 'package:flutter/services.dart';

class WordLimitInputFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitInputFormatter(this.maxWords);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    int wordCount = newValue.text.split(' ').length;

    if (wordCount > maxWords) {
      return oldValue;
    }

    return newValue;
  }
}
