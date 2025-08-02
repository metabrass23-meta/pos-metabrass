import 'package:flutter/foundation.dart';
import 'dart:convert';

class DebugHelper {
  static void printJson(String label, dynamic data) {
    if (kDebugMode) {
      print('=== $label ===');
      if (data is Map || data is List) {
        print(JsonEncoder.withIndent('  ').convert(data));
      } else {
        print(data.toString());
      }
      print('=== End $label ===\n');
    }
  }

  static void printApiResponse(String endpoint, dynamic response) {
    if (kDebugMode) {
      print('=== API Response: $endpoint ===');
      print('Response Type: ${response.runtimeType}');
      if (response != null) {
        printJson('Response Data', response);
      } else {
        print('Response is null');
      }
      print('=== End API Response ===\n');
    }
  }

  static void printError(String context, dynamic error) {
    if (kDebugMode) {
      print('=== ERROR in $context ===');
      print('Error Type: ${error.runtimeType}');
      print('Error Message: $error');
      if (error is Exception) {
        print('Stack Trace: ${error.toString()}');
      }
      print('=== End ERROR ===\n');
    }
  }

  static void printCategoryModel(String label, dynamic categoryData) {
    if (kDebugMode) {
      print('=== $label ===');
      print('Data Type: ${categoryData.runtimeType}');
      if (categoryData is Map<String, dynamic>) {
        print('Available fields:');
        categoryData.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }
      print('=== End $label ===\n');
    }
  }
}