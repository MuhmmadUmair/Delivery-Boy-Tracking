import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/utils/log_manager.dart';

class ManagerService {
  // ===================== Firebase =====================
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String apiKey = dotenv.env['PLACES_API_KEY']!;
  final DatabaseReference _rtdbRef = FirebaseDatabase.instance.ref(
    'delivery_boys',
  );

  // =====================================================
  // ================= CREATE MANAGER ====================
  Future<void> createManager({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      await _firestore.collection('managers').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'deliveryBoys': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      LogManager.logResponse(action: 'Create Manager', data: {'uid': uid});
    } catch (e, s) {
      LogManager.logError('Create Manager', e.toString(), s);
      throw AppException('Failed to create manager', 'ManagerService');
    }
  }

  Future<void> createManagerIfNotExists(User user) async {
    try {
      final ref = _firestore.collection('managers').doc(user.uid);
      if (!(await ref.get()).exists) {
        await createManager(
          uid: user.uid,
          name: user.displayName ?? 'No Name',
          email: user.email ?? '',
          phone: '',
          address: '',
        );
      }
    } catch (e, s) {
      LogManager.logError('Create Manager If Not Exists', e.toString(), s);
      throw AppException(
        'Failed to create manager if not exists',
        'ManagerService',
      );
    }
  }

  Future<bool> checkManagerExists(String uid) async {
    try {
      final doc = await _firestore.collection('managers').doc(uid).get();
      return doc.exists;
    } catch (e, s) {
      LogManager.logError('Check Manager Exists', e.toString(), s);
      throw AppException('Failed to check manager existence', 'ManagerService');
    }
  }

  // =====================================================
  // ================= LINK DELIVERY BOY =================
  Future<void> linkDeliveryBoyByCode(String deliveryCode) async {
    try {
      final manager = _auth.currentUser;
      if (manager == null) {
        throw AppException('Manager not logged in', 'ManagerService');
      }

      final query = await _firestore
          .collection('delivery_boys')
          .where('deliveryCode', isEqualTo: deliveryCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw AppException('Invalid delivery code', 'ManagerService');
      }

      final deliveryDoc = query.docs.first;

      if (deliveryDoc['managerId'] != null) {
        throw AppException('Delivery boy already linked', 'ManagerService');
      }

      final batch = _firestore.batch();
      batch.update(deliveryDoc.reference, {'managerId': manager.uid});
      batch.update(_firestore.collection('managers').doc(manager.uid), {
        'deliveryBoys': FieldValue.arrayUnion([deliveryDoc.id]),
      });

      await batch.commit();
      LogManager.logResponse(
        action: 'Link DeliveryBoy',
        data: {'deliveryCode': deliveryCode},
      );
    } catch (e, s) {
      LogManager.logError('Link DeliveryBoy', e.toString(), s);
      if (e is AppException) throw e;
      throw AppException('Failed to link delivery boy', 'ManagerService');
    }
  }

  Future<void> linkDeliveryBoyWithUI({
    required String deliveryCode,
    required BuildContext context,
  }) async {
    try {
      await linkDeliveryBoyByCode(deliveryCode);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery boy linked successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is AppException ? e.userMessage : 'Unknown error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  // =====================================================
  // ================= MANAGER DATA ======================
  Stream<DocumentSnapshot<Map<String, dynamic>>> getManagerStream() {
    final manager = _auth.currentUser;
    if (manager == null) {
      throw AppException('Manager not logged in', 'ManagerService');
    }
    return _firestore.collection('managers').doc(manager.uid).snapshots();
  }

  Future<Map<String, dynamic>?> getManagerData() async {
    try {
      final manager = _auth.currentUser;
      if (manager == null) return null;

      final doc = await _firestore
          .collection('managers')
          .doc(manager.uid)
          .get();
      return doc.data();
    } catch (e, s) {
      LogManager.logError('Get Manager Data', e.toString(), s);
      throw AppException('Failed to fetch manager data', 'ManagerService');
    }
  }

  // =====================================================
  // ================= DELIVERY BOYS =====================
  Future<List<Map<String, dynamic>>> getDeliveryBoys() async {
    try {
      final manager = _auth.currentUser;
      if (manager == null) return [];

      final snapshot = await _firestore
          .collection('delivery_boys')
          .where('managerId', isEqualTo: manager.uid)
          .get();

      return snapshot.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
    } catch (e, s) {
      LogManager.logError('Get DeliveryBoys', e.toString(), s);
      throw AppException('Failed to fetch delivery boys', 'ManagerService');
    }
  }

  Stream<DatabaseEvent> getDeliveryBoysRealtime() => _rtdbRef.onValue;

  Future<Map<String, dynamic>?> getDeliveryBoyByCode(
    String deliveryCode,
  ) async {
    try {
      final query = await _firestore
          .collection('delivery_boys')
          .where('deliveryCode', isEqualTo: deliveryCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return {...query.docs.first.data(), 'uid': query.docs.first.id};
    } catch (e, s) {
      LogManager.logError('Get DeliveryBoy By Code', e.toString(), s);
      throw AppException(
        'Failed to fetch delivery boy by code',
        'ManagerService',
      );
    }
  }

  // =====================================================
  // ================= ASSIGN ORDER ======================
  Future<String> assignOrder({
    required String deliveryBoyId,
    required String customerName,
    required String customerPhone,
    required Map<String, double> dropLocation,
    Map<String, double>? pickupLocation,
    String description = '',
  }) async {
    try {
      final manager = _auth.currentUser;
      if (manager == null) {
        throw AppException('Manager not logged in', 'ManagerService');
      }

      // Generate random 6-character order code
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rnd = Random();
      final orderCode = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );

      final ref = _firestore.collection('orders').doc();
      final orderId = ref.id;

      await ref.set({
        'orderId': orderId,
        'orderCode': orderCode,
        'managerId': manager.uid,
        'deliveryBoyId': deliveryBoyId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'pickupLocation': pickupLocation,
        'dropLocation': dropLocation,
        'description': description,
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
        'pickupTime': null,
        'deliveryTime': null,
        'stopTime': null,
      });

      // Add order reference to delivery boy
      await _firestore.collection('delivery_boys').doc(deliveryBoyId).update({
        'orders': FieldValue.arrayUnion([orderId]),
      });

      // Optionally update RTDB status to busy
      await _rtdbRef.child(deliveryBoyId).update({'status': 'busy'});

      LogManager.logResponse(
        action: 'Assign Order',
        data: {'orderId': orderId, 'orderCode': orderCode},
      );
      return orderCode;
    } catch (e, s) {
      LogManager.logError('Assign Order', e.toString(), s);
      throw AppException('Failed to assign order', 'ManagerService');
    }
  }

  // =====================================================
  // ================= ORDER HISTORY =====================
  Future<List<Map<String, dynamic>>> getOrderHistory(
    String deliveryBoyId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('deliveryBoyId', isEqualTo: deliveryBoyId)
          .orderBy('assignedAt', descending: true)
          .get();

      return snapshot.docs.map((d) => {...d.data(), 'orderId': d.id}).toList();
    } catch (e, s) {
      LogManager.logError('Get Order History', e.toString(), s);
      throw AppException('Failed to fetch order history', 'ManagerService');
    }
  }

  // =====================================================
  // ================= MERGE RTDB + FIRESTORE ===========
  List<Map<String, dynamic>> mergeDeliveryBoys(
    List<Map<String, dynamic>> firestoreBoys,
    Map<String, dynamic> rtdbData,
  ) {
    return firestoreBoys.map((data) {
      final uid = data['uid'];
      final rtdbBoy = rtdbData[uid] as Map?;

      DateTime? lastUpdated;
      if (rtdbBoy?['lastUpdated'] != null) {
        lastUpdated = DateTime.fromMillisecondsSinceEpoch(
          rtdbBoy!['lastUpdated'],
        );
      }

      return {
        'uid': uid,
        'name': data['name'] ?? 'Unknown',
        'address': data['address'] ?? '',
        'createdAt': data['createdAt'],
        'status': rtdbBoy?['status'] ?? 'offline',
        'lastStatusUpdate': lastUpdated,
        'lastLocation': rtdbBoy?['location'],
      };
    }).toList();
  }

  // ================= DELIVERY BOYS STREAM =================
  Stream<QuerySnapshot<Map<String, dynamic>>> getDeliveryBoysStream() {
    final manager = _auth.currentUser;
    if (manager == null) {
      throw AppException('Manager not logged in', 'ManagerService');
    }

    return _firestore
        .collection('delivery_boys')
        .where('managerId', isEqualTo: manager.uid)
        .snapshots();
  }

  // =====================================================
  // ================= STATS =============================
  Map<String, dynamic> calculateStats(List<Map<String, dynamic>> boys) {
    int total = boys.length;
    int active = boys.where((b) {
      final s = getRealTimeStatus(b);
      return s == 'moving' || s == 'idle';
    }).length;

    int offline = total - active;
    double totalDistance = 0.0;
    double successRate = total == 0 ? 0 : (active / total) * 100;

    return {
      'total': total,
      'active': active,
      'offline': offline,
      'totalDistance': totalDistance,
      'successRate': successRate,
    };
  }

  // =====================================================
  // ================= HELPERS ===========================
  String getRealTimeStatus(Map<String, dynamic> data) {
    final DateTime? last = data['lastStatusUpdate'];
    if (last == null) return 'offline';
    if (DateTime.now().difference(last).inSeconds > 60) return 'offline';
    return (data['status'] ?? 'idle').toString().toLowerCase();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'moving':
        return Colors.green;
      case 'idle':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
