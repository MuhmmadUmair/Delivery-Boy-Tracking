import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/data/response/api_response.dart';
import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/view/auth/manager/signup_screen.dart';
import 'package:firebase_google_apple_notif/view/auth/user/signup_screen.dart';

class AuthService {
  // ---------------- Firebase Instances ----------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Timer? _heartbeatTimer;

  String? get currentUserId => _auth.currentUser?.uid;

  // ===================================================
  // CREATE ACCOUNT
  // ===================================================
  Future<ApiResponse<User>> createAccount({
    required String email,
    required String password,
    required String name,
    required UserType profileType,
    required String phone,
    required String address,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (profileType == UserType.manager) {
        await _createManager(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
        );
      } else {
        await _createDeliveryBoy(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
        );
        await _setOnlineAndStartHeartbeat(credential.user!.uid);
      }

      return ApiResponse.completed(credential.user!);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ===================================================
  // MANAGER CREATION
  // ===================================================
  Future<void> _createManager({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    await _firestore.collection('managers').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'deliveryBoys': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ===================================================
  // DELIVERY BOY CREATION
  // ===================================================
  Future<void> _createDeliveryBoy({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final location = await _getCurrentLocation();

    await _firestore.collection('delivery_boys').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'deliveryCode': _generateDeliveryCode(),
      'managerId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final ref = _realtimeDB.ref('delivery_boys/$uid');

    await ref.set({
      'status': 'offline',
      'location': location ?? {'lat': 0.0, 'lng': 0.0},
      'lastUpdated': ServerValue.timestamp,
    });

    await ref.child('status').onDisconnect().set('offline');
  }

  // ===================================================
  // STATUS & HEARTBEAT
  // ===================================================
  Future<void> _setOnlineAndStartHeartbeat(String uid) async {
    await setDeliveryBoyStatus(uid, 'idle');
    _startHeartbeat(uid);
    _listenFirebaseConnection(uid);
  }

  Future<void> setDeliveryBoyStatus(String uid, String status) async {
    final ref = _realtimeDB.ref('delivery_boys/$uid');
    await ref.update({'status': status, 'lastUpdated': ServerValue.timestamp});

    if (status != 'offline') {
      await ref.child('status').onDisconnect().set('offline');
    }
  }

  void _startHeartbeat(String uid) {
    _heartbeatTimer?.cancel();

    final ref = _realtimeDB.ref('delivery_boys/$uid');

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (_auth.currentUser == null) {
        _heartbeatTimer?.cancel();
        return;
      }

      await ref.update({'lastUpdated': ServerValue.timestamp});
    });
  }

  void _listenFirebaseConnection(String uid) {
    _realtimeDB.ref('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == true) {
        setDeliveryBoyStatus(uid, 'idle');
      }
    });
  }

  Future<void> updateDeliveryBoyLocation(String uid, Position position) async {
    final ref = _realtimeDB.ref('delivery_boys/$uid/location');

    await ref.set({
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': ServerValue.timestamp,
    });

    await setDeliveryBoyStatus(uid, 'moving');
  }

  // ===================================================
  // GOOGLE SIGN IN
  // ===================================================
  Future<ApiResponse<User>> signInWithGoogle({
    required UserType profileType,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse.error('Sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      final collection = profileType == UserType.manager
          ? 'managers'
          : 'delivery_boys';

      final docRef = _firestore.collection(collection).doc(result.user!.uid);

      if (!(await docRef.get()).exists) {
        profileType == UserType.manager
            ? await _createManager(
                uid: result.user!.uid,
                name: result.user!.displayName ?? '',
                email: result.user!.email ?? '',
                phone: '',
                address: '',
              )
            : await _createDeliveryBoy(
                uid: result.user!.uid,
                name: result.user!.displayName ?? '',
                email: result.user!.email ?? '',
                phone: '',
                address: '',
              );
      }

      if (profileType == UserType.delivery) {
        await _setOnlineAndStartHeartbeat(result.user!.uid);
      }

      return ApiResponse.completed(result.user!);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ===================================================
  // EMAIL SIGN IN
  // ===================================================
  Future<ApiResponse<User>> signInWithEmail({
    required String email,
    required String password,
    required UserType profileType,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final collection = profileType == UserType.manager
          ? 'managers'
          : 'delivery_boys';

      final doc = await _firestore
          .collection(collection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        await signOut();
        return ApiResponse.error('Invalid role');
      }

      if (profileType == UserType.delivery) {
        await _setOnlineAndStartHeartbeat(credential.user!.uid);
      }

      return ApiResponse.completed(credential.user!);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ===================================================
  // SIGN OUT
  // ===================================================
  Future<ApiResponse<void>> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;

      _heartbeatTimer?.cancel();

      if (uid != null) {
        await setDeliveryBoyStatus(uid, 'offline');
      }

      await _googleSignIn.signOut();
      await _auth.signOut();

      return ApiResponse.completed(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ===================================================
  // LINK DELIVERY BOY
  // ===================================================
  Future<ApiResponse<void>> linkDeliveryBoyToManager({
    required String managerId,
    required String deliveryCode,
  }) async {
    try {
      final query = await _firestore
          .collection('delivery_boys')
          .where('deliveryCode', isEqualTo: deliveryCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return ApiResponse.error('Invalid delivery code');
      }

      final deliveryDoc = query.docs.first;

      if (deliveryDoc['managerId'] != null) {
        return ApiResponse.error('Already linked');
      }

      final batch = _firestore.batch();
      batch.update(deliveryDoc.reference, {'managerId': managerId});
      batch.update(_firestore.collection('managers').doc(managerId), {
        'deliveryBoys': FieldValue.arrayUnion([deliveryDoc.id]),
      });

      await batch.commit();
      return ApiResponse.completed(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // ===================================================
  // HELPERS
  // ===================================================
  String _generateDeliveryCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(5, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<Map<String, double>?> _getCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      return {'lat': pos.latitude, 'lng': pos.longitude};
    } catch (e) {
      log('Location error: $e');
      return null;
    }
  }

  String _handleError(dynamic e) {
    if (e is FirebaseAuthException) return e.message ?? 'Auth error';
    if (e is AppException) return e.userMessage;
    return e.toString();
  }

  // ===================================================
  // NAVIGATION
  // ===================================================
  static void gotoSignup(BuildContext context, UserType profileType) {
    final page = profileType == UserType.manager
        ? const ManagerSignupScreen()
        : const DeliverySignupScreen();

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
