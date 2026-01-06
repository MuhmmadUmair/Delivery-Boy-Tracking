import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/utils/log_manager.dart';

class DeliveryService {
  // ===================== Firebase =====================
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get _user => _auth.currentUser;

  // ===================== Connectivity =================
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // ===================== Heartbeat ====================
  Timer? _heartbeatTimer;

  // ===================== Online Status Stream =========
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  Stream<bool> get onlineStatusStream => _onlineController.stream;

  // ===================== INIT & DISPOSE ===============
  void init() {
    _listenConnectivity();
    if (_user != null) {
      _setupOnDisconnect(_user!.uid);
      _startHeartbeat(_user!.uid);
    }
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _connectivitySub?.cancel();
    _onlineController.close();
  }

  // ===================================================
  // ================= CHECK EXISTS ====================
  Future<bool> checkDeliveryBoyExists(String uid) async {
    try {
      final doc = await _firestore.collection('delivery_boys').doc(uid).get();
      return doc.exists;
    } catch (e, s) {
      LogManager.logError('Check DeliveryBoy Exists', e.toString(), s);
      throw AppException(
        'Failed to check delivery boy existence',
        'DeliveryService',
      );
    }
  }

  // ===================================================
  // ================= CREATE DELIVERY BOY =============
  Future<void> createDeliveryBoy({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final location = await _getCurrentLocation();

      // Firestore
      await _firestore.collection('delivery_boys').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'deliveryCode': _generateDeliveryCode(),
        'managerId': null,
        'orders': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Realtime DB
      final ref = _realtimeDB.ref('delivery_boys/$uid');
      await ref.set({
        'status': 'offline',
        'location': location ?? {'lat': 0.0, 'lng': 0.0},
        'lastUpdated': ServerValue.timestamp,
      });

      await _setupOnDisconnect(uid);
      LogManager.logResponse(action: 'Create DeliveryBoy', data: {'uid': uid});
    } catch (e, s) {
      LogManager.logError('Create DeliveryBoy', e.toString(), s);
      throw AppException('Failed to create delivery boy', 'DeliveryService');
    }
  }

  Future<void> createDeliveryBoyIfNotExists([User? user]) async {
    try {
      final currentUser = user ?? _user;
      if (currentUser == null) return;

      final exists = await checkDeliveryBoyExists(currentUser.uid);
      if (!exists) {
        await createDeliveryBoy(
          uid: currentUser.uid,
          name: currentUser.displayName ?? '',
          email: currentUser.email ?? '',
          phone: '',
          address: '',
        );
      }
    } catch (e, s) {
      LogManager.logError('Create DeliveryBoyIfNotExists', e.toString(), s);
      throw AppException(
        'Failed to create delivery boy if not exists',
        'DeliveryService',
      );
    }
  }

  // ===================================================
  // ================= ONLINE / OFFLINE ================
  Future<void> setOnlineAndStartHeartbeat(String uid) async {
    try {
      await _setStatus(uid, 'idle');
      _startHeartbeat(uid);
      _listenFirebaseConnection(uid);
      LogManager.logResponse(action: 'Set Online', data: {'uid': uid});
    } catch (e, s) {
      LogManager.logError('Set Online', e.toString(), s);
      throw AppException('Failed to set online', 'DeliveryService');
    }
  }

  Future<void> setOffline(String uid) async {
    try {
      _heartbeatTimer?.cancel();
      await _setStatus(uid, 'offline');
      LogManager.logResponse(action: 'Set Offline', data: {'uid': uid});
    } catch (e, s) {
      LogManager.logError('Set Offline', e.toString(), s);
      throw AppException('Failed to set offline', 'DeliveryService');
    }
  }

  Future<void> setOnline(bool online) async {
    if (_user == null) return;

    try {
      if (online) {
        await setOnlineAndStartHeartbeat(_user!.uid);
      } else {
        await setOffline(_user!.uid);
      }
    } catch (e, s) {
      LogManager.logError('Set Online Status', e.toString(), s);
      throw AppException('Failed to set online status', 'DeliveryService');
    }
  }

  Future<void> _setStatus(String uid, String status) async {
    try {
      final ref = _realtimeDB.ref('delivery_boys/$uid');
      await ref.update({
        'status': status,
        'lastUpdated': ServerValue.timestamp,
      });
      _onlineController.add(status != 'offline');

      if (status != 'offline') {
        await _setupOnDisconnect(uid);
      }
    } catch (e, s) {
      LogManager.logError('_SetStatus', e.toString(), s);
      throw AppException('Failed to update status', 'DeliveryService');
    }
  }

  Future<void> _setupOnDisconnect(String uid) async {
    try {
      final ref = _realtimeDB.ref('delivery_boys/$uid');
      await ref.child('status').onDisconnect().set('offline');
      await ref.child('lastUpdated').onDisconnect().set(ServerValue.timestamp);
    } catch (e, s) {
      LogManager.logError('_SetupOnDisconnect', e.toString(), s);
      throw AppException('Failed to setup onDisconnect', 'DeliveryService');
    }
  }

  void _startHeartbeat(String uid) {
    _heartbeatTimer?.cancel();
    final ref = _realtimeDB.ref('delivery_boys/$uid');

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      try {
        if (_auth.currentUser == null) return;
        await ref.update({'lastUpdated': ServerValue.timestamp});
      } catch (e, s) {
        LogManager.logError('Heartbeat Update', e.toString(), s);
      }
    });
  }

  void _listenFirebaseConnection(String uid) {
    _realtimeDB.ref('.info/connected').onValue.listen((event) async {
      try {
        if (event.snapshot.value == true) {
          await _setStatus(uid, 'idle');
        }
      } catch (e, s) {
        LogManager.logError('Firebase Connection Listener', e.toString(), s);
      }
    });
  }

  // ===================================================
  // ================= CONNECTIVITY ====================
  void _listenConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      final user = _auth.currentUser;
      if (user == null) return;

      final connected = results.any((r) => r != ConnectivityResult.none);

      try {
        if (connected) {
          await setOnlineAndStartHeartbeat(user.uid);
        } else {
          await setOffline(user.uid);
        }
      } catch (e, s) {
        LogManager.logError('Connectivity Listener', e.toString(), s);
      }
    });
  }

  // ===================================================
  // ================= LOCATION ========================
  Future<void> updateLocation(Position position) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _realtimeDB.ref('delivery_boys/${user.uid}/location').set({
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': ServerValue.timestamp,
      });

      await _realtimeDB.ref('delivery_boys/${user.uid}').update({
        'status': 'moving',
        'lastUpdated': ServerValue.timestamp,
      });

      LogManager.logResponse(
        action: 'Update Location',
        data: {
          'uid': user.uid,
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );
    } catch (e, s) {
      LogManager.logError('Update Location', e.toString(), s);
      throw AppException('Failed to update location', 'DeliveryService');
    }
  }

  Future<Map<String, double>?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {'lat': pos.latitude, 'lng': pos.longitude};
    } catch (e, s) {
      LogManager.logError('Get Current Location', e.toString(), s);
      return null;
    }
  }

  // ===================================================
  // ================= ORDERS ==========================
  Future<String> createOrder({
    required String deliveryBoyId,
    required String customerName,
    required String customerPhone,
    required Map<String, double> dropLocation,
    Map<String, double>? pickupLocation,
    String description = '',
  }) async {
    try {
      final orderRef = _firestore.collection('orders').doc();
      final orderId = orderRef.id;

      await orderRef.set({
        'orderId': orderId,
        'managerId': _auth.currentUser!.uid,
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
      });

      await _firestore.collection('delivery_boys').doc(deliveryBoyId).update({
        'orders': FieldValue.arrayUnion([orderId]),
      });

      LogManager.logResponse(
        action: 'Create Order',
        data: {'orderId': orderId},
      );
      return orderId;
    } catch (e, s) {
      LogManager.logError('Create Order', e.toString(), s);
      throw AppException('Failed to create order', 'DeliveryService');
    }
  }

  /// Fetch recent orders for a delivery boy (No index required)
  Future<List<Map<String, dynamic>>> fetchOrders({
    required String deliveryBoyId,
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('deliveryBoyId', isEqualTo: deliveryBoyId)
          .limit(limit * 2) // Fetch more to sort in memory
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'orderId': doc.id,
          'customerName': data['customerName'] ?? '',
          'customerPhone': data['customerPhone'] ?? '',
          'pickup': data['pickupLocation'],
          'drop': data['dropLocation'],
          'status': data['status'] ?? 'assigned',
          'description': data['description'] ?? '',
          'assignedAt': data['assignedAt'],
        };
      }).toList();

      // Sort in memory by assignedAt (newest first)
      orders.sort((a, b) {
        final aTime = a['assignedAt'] as Timestamp?;
        final bTime = b['assignedAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending order
      });

      return orders.take(limit).toList();
    } catch (e, s) {
      LogManager.logError('Fetch Orders', e.toString(), s);
      throw AppException('Failed to fetch orders', 'DeliveryService');
    }
  }

  /// Stream orders for live updates (No index required)
  Stream<List<Map<String, dynamic>>> streamOrders({
    String? deliveryBoyId,
    int limit = 10,
  }) {
    final uid = deliveryBoyId ?? _user?.uid;
    if (uid == null) return const Stream.empty();

    try {
      return _firestore
          .collection('orders')
          .where('deliveryBoyId', isEqualTo: uid)
          .limit(limit * 2) // Fetch more to sort in memory
          .snapshots()
          .map((snapshot) {
            final orders = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'orderId': doc.id,
                'customerName': data['customerName'] ?? '',
                'customerPhone': data['customerPhone'] ?? '',
                'pickup': data['pickupLocation'],
                'drop': data['dropLocation'],
                'status': data['status'] ?? 'assigned',
                'description': data['description'] ?? '',
                'assignedAt': data['assignedAt'],
              };
            }).toList();

            // Sort in memory by assignedAt (newest first)
            orders.sort((a, b) {
              final aTime = a['assignedAt'] as Timestamp?;
              final bTime = b['assignedAt'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime); // Descending order
            });

            return orders.take(limit).toList();
          })
          .handleError((error, stackTrace) {
            LogManager.logError(
              'Stream Orders Error',
              error.toString(),
              stackTrace,
            );
            return <Map<String, dynamic>>[];
          });
    } catch (e, s) {
      LogManager.logError('Stream Orders', e.toString(), s);
      return Stream.error(e);
    }
  }

  // ===================================================
  // ================= STATS ==========================
  Future<Map<String, dynamic>> computeOrderStats(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('deliveryBoyId', isEqualTo: uid)
          .get();

      final total = snapshot.docs.length;
      final completed = snapshot.docs
          .where((d) => d['status'] == 'done' || d['status'] == 'delivered')
          .length;

      return {
        'totalOrders': total,
        'completedOrders': completed,
        'successRate': total == 0
            ? '0%'
            : '${((completed / total) * 100).round()}%',
      };
    } catch (e, s) {
      LogManager.logError('Compute Order Stats', e.toString(), s);
      throw AppException('Failed to compute order stats', 'DeliveryService');
    }
  }

  // ===================================================
  // ================= HELPERS =========================
  String _generateDeliveryCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(5, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
