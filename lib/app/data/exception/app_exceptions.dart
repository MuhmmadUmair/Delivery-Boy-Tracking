import 'dart:convert';

/// Base class for custom application exceptions.
class AppException implements Exception {
  AppException([this._message, this._prefix, this._rawBody]);

  final String? _message;
  final String? _prefix;
  final String? _rawBody;

  /// User-friendly message for UI
  String get userMessage => _message ?? 'Something went wrong';

  /// Developer-friendly debug info
  String get debugMessage {
    return '$_prefix: ${_message ?? 'No message'}'
        '${_rawBody != null ? '\nRaw Body: $_rawBody' : ''}';
  }

  @override
  String toString() => userMessage;
}

/// Exception class representing a fetch data error during communication.
class FetchDataException extends AppException {
  FetchDataException([String? responseBody])
    : super(_extractMessage(responseBody), 'Error During Communication');

  static String _extractMessage(String? responseBody) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(responseBody ?? '{}') as Map<String, dynamic>;
      return json['message'] as String? ??
          json['error'] as String? ??
          'Invalid request';
    } catch (_) {
      return 'Invalid request';
    }
  }
}

/// Exception class representing a bad request error.
class BadRequestException extends AppException {
  BadRequestException([String? responseBody])
    : super(_extractMessage(responseBody), 'Bad Request', responseBody);

  static String _extractMessage(String? responseBody) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(responseBody ?? '{}') as Map<String, dynamic>;
      return json['message'] as String? ??
          json['error'] as String? ??
          'Invalid request';
    } catch (_) {
      return 'Invalid request';
    }
  }
}

/// Exception class representing an unauthorized request error.
class UnauthorizedException extends AppException {
  UnauthorizedException([String? responseBody])
    : super(_extractMessage(responseBody), 'Unauthorized', responseBody);

  static String _extractMessage(String? responseBody) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(responseBody ?? '{}') as Map<String, dynamic>;
      return json['message'] as String? ??
          json['error'] as String? ??
          'You are not authorized';
    } catch (_) {
      return 'You are not authorized';
    }
  }
}

/// Exception class representing an invalid input error.
class InvalidInputException extends AppException {
  InvalidInputException([String? message])
    : super(message ?? 'Invalid input provided', 'Invalid Input');
}

/// Exception class representing a no internet connection error.
class NoInternetException extends AppException {
  NoInternetException([String? message])
    : super(message ?? 'Please check your internet connection', 'Network');
}
