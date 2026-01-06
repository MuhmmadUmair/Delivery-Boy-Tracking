import 'dart:io';

import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/data/response/api_response.dart';
import 'package:firebase_google_apple_notif/app/utils/log_manager.dart';
import 'package:firebase_google_apple_notif/services/common/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase-specific API service
/// Handles Firestore, Storage, and session token
class NetworkApiService {
  final SessionController _sessionController = SessionController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ================== Firestore ==================

  Future<ApiResponse<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      LogManager.logRequest(
        action: 'Get Document',
        body: {'collection': collection, 'docId': docId},
      );

      final docSnapshot = await _firestore
          .collection(collection)
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return ApiResponse.completed(docSnapshot.data()!);
      } else {
        // Use AppException instead of undefined FetchDataException
        final exception = AppException('Document not found', 'Firestore');
        return ApiResponse.error(exception.userMessage);
      }
    } catch (e, s) {
      LogManager.logError('Get Document', e.toString(), s);
      return ApiResponse.error(_handleFirebaseException(e).userMessage);
    }
  }

  Future<ApiResponse<void>> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      LogManager.logRequest(
        action: 'Set Document',
        body: {'collection': collection, 'docId': docId, 'data': data},
      );

      await _firestore.collection(collection).doc(docId).set(data);
      return const ApiResponse.completed(null);
    } catch (e, s) {
      LogManager.logError('Set Document', e.toString(), s);
      return ApiResponse.error(_handleFirebaseException(e).userMessage);
    }
  }

  Future<ApiResponse<void>> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      LogManager.logRequest(
        action: 'Update Document',
        body: {'collection': collection, 'docId': docId, 'data': data},
      );

      await _firestore.collection(collection).doc(docId).update(data);
      return const ApiResponse.completed(null);
    } catch (e, s) {
      LogManager.logError('Update Document', e.toString(), s);
      return ApiResponse.error(_handleFirebaseException(e).userMessage);
    }
  }

  Future<ApiResponse<void>> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      LogManager.logRequest(
        action: 'Delete Document',
        body: {'collection': collection, 'docId': docId},
      );

      await _firestore.collection(collection).doc(docId).delete();
      return const ApiResponse.completed(null);
    } catch (e, s) {
      LogManager.logError('Delete Document', e.toString(), s);
      return ApiResponse.error(_handleFirebaseException(e).userMessage);
    }
  }

  /// ================== Firebase Storage ==================
  Future<ApiResponse<String>> uploadFile({
    required File file,
    required String path,
  }) async {
    try {
      LogManager.logRequest(
        action: 'Upload File',
        body: {'path': path, 'file': file.path},
      );

      final ref = _storage.ref().child(path);
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return ApiResponse.completed(downloadUrl);
    } catch (e, s) {
      LogManager.logError('Upload File', e.toString(), s);
      return ApiResponse.error(_handleFirebaseException(e).userMessage);
    }
  }

  /// ================== Session ==================
  String? get token => _sessionController.token;

  /// ================== Private Firebase Exception Handler ==================
  AppException _handleFirebaseException(dynamic e) {
    return handleFirebaseException(e); // Uses AppException wrapper
  }
}
