import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple network test to verify API connectivity
class NetworkTest {
  static Future<bool> testConnection() async {
    try {
      final client = HttpClient();
      // Set timeout to 5 seconds
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(
        Uri.parse('https://api.proximate.app/health'),
      );
      final response = await request.close();

      client.close();

      if (response.statusCode == 200) {
        debugPrint('✅ Network connection successful');
        return true;
      } else {
        debugPrint('❌ Network connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Network connection error: $e');
      return false;
    }
  }
}
