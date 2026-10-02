import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5137/api';
      }
    } catch (e) {
      // Ignore if on web
    }
    return 'http://localhost:5137/api';
  }

  static String? formatImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    var formatted = url.trim();
    try {
      if (Platform.isAndroid) {
        if (formatted.contains('localhost:')) {
          formatted = formatted.replaceAll('localhost:', '10.0.2.2:');
        } else if (formatted.contains('127.0.0.1:')) {
          formatted = formatted.replaceAll('127.0.0.1:', '10.0.2.2:');
        }
      }
    } catch (_) {}
    return formatted;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

