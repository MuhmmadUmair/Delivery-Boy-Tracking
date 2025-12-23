import 'dart:convert';
import 'dart:developer';

class LogManager {
  static const _line = '══════════════════════════════════════════════════════';

  /// Logs an HTTP request
  static void logRequest(
    String method,
    String url,
    Map<String, dynamic>? body,
  ) {
    _printInSequence([
      _line,
      '📤 REQUEST [$method] → $url',
      if (body != null && body.isNotEmpty) _prettyJson('Body', body),
      _line,
    ]);
  }

  /// Logs an HTTP response
  static void logResponse(String statusCode, String responseBody) {
    final parsed = _tryParseJson(responseBody);

    _printInSequence([
      _line,
      '📥 RESPONSE ← Status: $statusCode',
      if (parsed != null)
        _prettyJson('Body', parsed)
      else
        'Body:\n$responseBody',
      _line,
    ]);
  }

  /// Logs an error
  static void logError(String message, [StackTrace? stackTrace]) {
    _printInSequence([
      _line,
      '❌ ERROR: $message',
      if (stackTrace != null) 'StackTrace:\n$stackTrace',
      _line,
    ]);
  }

  /// Internal: print each line in order using dart:developer's `log()`
  static void _printInSequence(List<String> lines) {
    for (final line in lines) {
      log(line);
    }
  }

  /// Internal: format JSON with indenting
  static String _prettyJson(String title, dynamic data) {
    // try {
    //   const encoder = JsonEncoder.withIndent('  ');
    //   return '$title:\n${encoder.convert(data)}';
    // } catch (_) {
    return '$title: $data';
    // }
  }

  /// Internal: safely parse string to JSON
  static dynamic _tryParseJson(String raw) {
    try {
      return json.decode(raw);
    } catch (_) {
      return null;
    }
  }
}
