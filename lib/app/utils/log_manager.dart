import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LogManager {
  static const _line = '══════════════════════════════════════════════════════';

  /// Logs an HTTP/Firebase-like request
  static void logRequest({
    required String action,
    String? method,
    String? collection,
    String? documentId,
    Map<String, dynamic>? body,
  }) {
    final msg = [
      _line,
      '📤 REQUEST → $action',
      if (method != null) 'Method: $method',
      if (collection != null) 'Collection: $collection',
      if (documentId != null) 'Document ID: $documentId',
      if (body != null && body.isNotEmpty) _prettyJson('Body', body),
      _line,
    ];
    _printInSequence(msg);
  }

  /// Logs a Firebase response/result
  static void logResponse({
    required String action,
    String? status,
    Map<String, dynamic>? data,
  }) {
    final msg = [
      _line,
      '📥 RESPONSE ← $action',
      if (status != null) 'Status: $status',
      if (data != null) _prettyJson('Data', data),
      _line,
    ];
    _printInSequence(msg);
  }

  /// Logs a generic error
  static void logError(
    String action,
    String message, [
    StackTrace? stackTrace,
  ]) {
    final msg = [
      _line,
      '❌ ERROR → $action',
      'Message: $message',
      if (stackTrace != null) 'StackTrace:\n$stackTrace',
      _line,
    ];
    _printInSequence(msg);
  }

  /// Logs Auth actions
  static void logAuthAction({
    required String action,
    User? user,
    String? extraInfo,
  }) {
    final msg = [
      _line,
      '🔑 AUTH → $action',
      if (user != null) 'UID: ${user.uid}, Email: ${user.email}',
      if (extraInfo != null) extraInfo,
      _line,
    ];
    _printInSequence(msg);
  }

  /// Logs ManagerService actions
  static void logManagerAction({
    required String action,
    String? managerId,
    Map<String, dynamic>? body,
  }) {
    final msg = [
      _line,
      '🏢 MANAGER SERVICE → $action',
      if (managerId != null) 'Manager UID: $managerId',
      if (body != null && body.isNotEmpty) _prettyJson('Body', body),
      _line,
    ];
    _printInSequence(msg);
  }

  /// Logs DeliveryService actions
  static void logDeliveryAction({
    required String action,
    String? deliveryBoyId,
    Map<String, dynamic>? body,
  }) {
    final msg = [
      _line,
      '🏍️ DELIVERY SERVICE → $action',
      if (deliveryBoyId != null) 'Delivery UID: $deliveryBoyId',
      if (body != null && body.isNotEmpty) _prettyJson('Body', body),
      _line,
    ];
    _printInSequence(msg);
  }

  /// Internal: safely print JSON or data
  static String _prettyJson(String title, dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return '$title:\n${encoder.convert(data)}';
    } catch (_) {
      return '$title: $data';
    }
  }

  /// Internal: print line by line
  static void _printInSequence(List<String> lines) {
    for (final line in lines) {
      log(line);
    }
  }

  // ==================== UTILITIES =====================
  /// Logs Firestore document fetch
  static void logFirestoreDoc({
    required String action,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    logResponse(
      action: action,
      data: {...doc.data() ?? {}, 'id': doc.id},
      status: doc.exists ? 'found' : 'not found',
    );
  }

  /// Logs RTDB snapshot
  static void logRTDBSnapshot({
    required String action,
    required DatabaseEvent event,
  }) {
    logResponse(
      action: action,
      data: event.snapshot.value is Map
          ? Map<String, dynamic>.from(event.snapshot.value as Map)
          : {'value': event.snapshot.value},
    );
  }

  /// Logs order assignment
  static void logOrderAssigned({
    required String orderId,
    required String managerId,
    required String deliveryBoyId,
    Map<String, dynamic>? orderData,
  }) {
    logManagerAction(
      action: 'Order Assigned',
      managerId: managerId,
      body: {'orderId': orderId, 'deliveryBoyId': deliveryBoyId, ...?orderData},
    );
  }

  /// Logs order creation from delivery boy
  static void logOrderCreated({
    required String orderId,
    required String deliveryBoyId,
    Map<String, dynamic>? orderData,
  }) {
    logDeliveryAction(
      action: 'Order Created',
      deliveryBoyId: deliveryBoyId,
      body: {'orderId': orderId, ...?orderData},
    );
  }
}
