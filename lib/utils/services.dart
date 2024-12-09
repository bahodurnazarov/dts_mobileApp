import 'package:flutter/services.dart';


class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text;

    // Remove any existing non-digit characters
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');

    // Format according to the desired pattern
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 5 || i == 7) buffer.write('-');
      buffer.write(digitsOnly[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
class PhoneNumberConverter {
  // Method to convert formatted phone number to plain format
  String convertToPlainPhoneNumber(String formattedNumber) {
    return formattedNumber.replaceAll('-', '');
  }
}