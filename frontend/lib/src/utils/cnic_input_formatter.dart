import 'package:flutter/services.dart';

class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 13 digits (CNIC length without dashes)
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }
    
    String formatted = '';
    
    // Add first dash after 5 digits
    if (digitsOnly.length > 5) {
      formatted = digitsOnly.substring(0, 5) + '-' + digitsOnly.substring(5);
    } else {
      formatted = digitsOnly;
    }
    
    // Add second dash after 7 more digits (total 12 digits)
    if (digitsOnly.length > 12) {
      formatted = formatted.substring(0, 13) + '-' + digitsOnly.substring(12);
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CnicTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // If user is trying to delete, allow it
    if (newValue.selection.end < oldValue.selection.end) {
      return newValue;
    }
    
    // Remove all non-digit characters
    String digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 13 digits
    if (digitsOnly.length > 13) {
      digitsOnly = digitsOnly.substring(0, 13);
    }
    
    String formatted = _formatCnic(digitsOnly);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
  
  String _formatCnic(String digits) {
    if (digits.isEmpty) return '';
    
    String formatted = digits;
    
    // Add first dash after 5 digits
    if (formatted.length > 5) {
      formatted = formatted.substring(0, 5) + '-' + formatted.substring(5);
    }
    
    // Add second dash after 7 more digits (total 12 digits)
    if (formatted.length > 13) {
      formatted = formatted.substring(0, 13) + '-' + formatted.substring(13);
    }
    
    return formatted;
  }
}
