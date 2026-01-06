import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ErrorHandler {
  static String? handle(
    BuildContext? context,
    Object error, {
    String? defaultMessage,
    String? serviceName,
  }) {
    final label = serviceName != null ? '[$serviceName]' : '[ErrorHandler]';
    String message =
        defaultMessage ?? 'Something went wrong. Please try again.';

    // Handle AppException (including Firebase exceptions)
    if (error is AppException) {
      debugPrint('$label ❌ ${error.debugMessage}');
      message = error.userMessage;
    }
    // Handle generic Firebase exceptions not wrapped yet
    else if (error is FirebaseAuthException) {
      debugPrint('$label ❌ FirebaseAuthException: ${error.code}');
      switch (error.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-not-found':
          message = 'No user found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password provided.';
          break;
        case 'network-request-failed':
          message = 'No internet connection.';
          break;
        default:
          message = error.message ?? 'Authentication error occurred.';
      }
    } else if (error is FirebaseException) {
      debugPrint('$label ❌ FirebaseException: ${error.code}');
      message = error.message ?? 'Firebase error occurred.';
    } else {
      debugPrint('$label ❌ Unexpected error: $error');

      final trace = StackTrace.current
          .toString()
          .split('\n')
          .take(10)
          .join('\n');
      debugPrint('$label 🧵 Stack trace:\n$trace');
    }

    // Show message in UI if context is available
    if (context != null && context.mounted) {
      context.flushBarErrorMessage(message: message);
    }

    return message;
  }
}
