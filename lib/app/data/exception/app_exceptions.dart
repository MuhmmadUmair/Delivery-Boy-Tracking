import 'package:firebase_auth/firebase_auth.dart';

/// Base class for Firebase-specific exceptions
class AppException implements Exception {
  AppException([this._message, this._prefix]);

  final String? _message;
  final String? _prefix;

  /// User-friendly message
  String get userMessage => _message ?? 'Something went wrong';

  /// Developer-friendly debug info
  String get debugMessage => '$_prefix: ${_message ?? 'No message'}';

  @override
  String toString() => userMessage;
}

/// Firebase Authentication Exceptions
class FirebaseAuthExceptionWrapper extends AppException {
  FirebaseAuthExceptionWrapper(FirebaseAuthException e)
    : super(_mapAuthCodeToMessage(e.code), 'Firebase Auth Error');

  static String _mapAuthCodeToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication error: $code';
    }
  }
}

/// Firestore Exceptions
class FirestoreExceptionWrapper extends AppException {
  FirestoreExceptionWrapper(FirebaseException e)
    : super(_mapFirestoreError(e), 'Firestore Error');

  static String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'deadline-exceeded':
        return 'The operation timed out.';
      case 'internal':
        return 'Internal Firestore error.';
      case 'not-found':
        return 'Requested document or collection not found.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is currently unavailable. Try later.';
      case 'resource-exhausted':
        return 'Resource limits exceeded.';
      case 'unauthenticated':
        return 'You must be authenticated to perform this action.';
      default:
        return 'Firestore error: ${e.code}';
    }
  }
}

/// Realtime Database Exceptions
class RealtimeDatabaseExceptionWrapper extends AppException {
  RealtimeDatabaseExceptionWrapper(FirebaseException e)
    : super(_mapDatabaseError(e), 'Realtime Database Error');

  static String _mapDatabaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access this data.';
      case 'disconnected':
        return 'Network disconnected.';
      case 'network-error':
        return 'Network error. Please try again.';
      case 'unavailable':
        return 'Service unavailable. Try again later.';
      default:
        return 'Realtime Database error: ${e.code}';
    }
  }
}

/// Firebase Storage Exceptions
class FirebaseStorageExceptionWrapper extends AppException {
  FirebaseStorageExceptionWrapper(FirebaseException e)
    : super(_mapStorageError(e), 'Firebase Storage Error');

  static String _mapStorageError(FirebaseException e) {
    switch (e.code) {
      case 'object-not-found':
        return 'The file you are trying to access does not exist.';
      case 'bucket-not-found':
        return 'Storage bucket not found.';
      case 'quota-exceeded':
        return 'Storage quota exceeded.';
      case 'unauthenticated':
        return 'You must be logged in to access this file.';
      case 'unauthorized':
        return 'You do not have permission to access this file.';
      case 'retry-limit-exceeded':
        return 'Retry limit exceeded. Try again later.';
      case 'cancelled':
        return 'Operation cancelled.';
      default:
        return 'Storage error: ${e.code}';
    }
  }
}

/// Generic Firebase Exception (for other FirebaseErrors)
class GenericFirebaseExceptionWrapper extends AppException {
  GenericFirebaseExceptionWrapper(FirebaseException e)
    : super(e.message ?? 'Unknown Firebase error', 'Firebase Error');
}

/// Utility function to handle Firebase exceptions dynamically
AppException handleFirebaseException(dynamic e) {
  if (e is FirebaseAuthException) {
    return FirebaseAuthExceptionWrapper(e);
  } else if (e is FirebaseException) {
    // Decide which service based on message or code
    if (e.plugin == 'cloud_firestore') return FirestoreExceptionWrapper(e);
    if (e.plugin == 'firebase_database')
      return RealtimeDatabaseExceptionWrapper(e);
    if (e.plugin == 'firebase_storage')
      return FirebaseStorageExceptionWrapper(e);
    return GenericFirebaseExceptionWrapper(e);
  } else {
    return AppException(e.toString(), 'Unknown Error');
  }
}
