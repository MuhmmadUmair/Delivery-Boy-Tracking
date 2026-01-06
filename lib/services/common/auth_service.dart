import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:firebase_google_apple_notif/services/delivery_serivce.dart';
import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/data/response/api_response.dart';
import 'package:firebase_google_apple_notif/app/utils/log_manager.dart';
import 'package:firebase_google_apple_notif/view/auth/manager/signup_screen.dart';
import 'package:firebase_google_apple_notif/view/auth/user/signup_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  String? get currentUserId => _auth.currentUser?.uid;

  // ================= CREATE ACCOUNT =================
  Future<ApiResponse<User>> createAccount({
    required String email,
    required String password,
    required String name,
    required UserType profileType,
    required String phone,
    required String address,
  }) async {
    LogManager.logRequest(
      action: 'Create Account',
      body: {'email': email, 'name': name, 'profileType': profileType.name},
    );

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      final uid = user.uid;

      if (profileType == UserType.manager) {
        await ManagerService().createManager(
          uid: uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
        );
      } else {
        final deliveryService = DeliveryService();
        await deliveryService.createDeliveryBoy(
          uid: uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
        );
        await deliveryService.setOnlineAndStartHeartbeat(uid);
      }

      LogManager.logResponse(action: 'Create Account', data: {'uid': uid});
      return ApiResponse.completed(user);
    } on FirebaseAuthException catch (e) {
      LogManager.logError('Create Account', e.message ?? e.code);
      throw AppException(e.message ?? 'Authentication error', 'FirebaseAuth');
    } catch (e, s) {
      LogManager.logError('Create Account', e.toString(), s);
      throw AppException(e.toString(), 'AuthService');
    }
  }

  // ================= EMAIL LOGIN =================
  Future<ApiResponse<User>> signInWithEmail({
    required String email,
    required String password,
    required UserType profileType,
  }) async {
    LogManager.logRequest(
      action: 'Email Login',
      body: {'email': email, 'profileType': profileType.name},
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      final uid = user.uid;

      // Check if user exists in Firestore
      final exists = profileType == UserType.manager
          ? await ManagerService().checkManagerExists(uid)
          : await DeliveryService().checkDeliveryBoyExists(uid);

      if (!exists) {
        await signOut();
        throw AppException(
          'User role mismatch or account does not exist',
          'AuthService',
        );
      }

      if (profileType == UserType.delivery) {
        await DeliveryService().setOnlineAndStartHeartbeat(uid);
      }

      LogManager.logResponse(action: 'Email Login', data: {'uid': uid});
      return ApiResponse.completed(user);
    } on FirebaseAuthException catch (e) {
      LogManager.logError('Email Login', e.message ?? e.code);
      throw AppException(e.message ?? 'Authentication error', 'FirebaseAuth');
    } catch (e, s) {
      LogManager.logError('Email Login', e.toString(), s);
      throw AppException(e.toString(), 'AuthService');
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<ApiResponse<User>> signInWithGoogle({
    required UserType profileType,
  }) async {
    LogManager.logRequest(
      action: 'Google Login',
      body: {'profileType': profileType.name},
    );

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AppException('Google sign-in cancelled', 'AuthService');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;
      final uid = user.uid;

      if (profileType == UserType.manager) {
        await ManagerService().createManagerIfNotExists(user);
      } else {
        final deliveryService = DeliveryService();
        await deliveryService.createDeliveryBoyIfNotExists(user);
        await deliveryService.setOnlineAndStartHeartbeat(uid);
      }

      LogManager.logResponse(action: 'Google Login', data: {'uid': uid});
      return ApiResponse.completed(user);
    } on FirebaseAuthException catch (e) {
      LogManager.logError('Google Login', e.message ?? e.code);
      throw AppException(e.message ?? 'Authentication error', 'FirebaseAuth');
    } catch (e, s) {
      LogManager.logError('Google Login', e.toString(), s);
      throw AppException(e.toString(), 'AuthService');
    }
  }

  // ================= SIGN OUT =================
  Future<ApiResponse<void>> signOut() async {
    LogManager.logRequest(action: 'Sign Out');

    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await DeliveryService().setOffline(uid);
      }

      await _googleSignIn.signOut();
      await _auth.signOut();

      LogManager.logResponse(action: 'Sign Out', data: {'success': true});
      return const ApiResponse.completed(null);
    } catch (e, s) {
      LogManager.logError('Sign Out', e.toString(), s);
      throw AppException(e.toString(), 'AuthService');
    }
  }

  // ================= NAVIGATION =================
  static void gotoSignup(BuildContext context, UserType profileType) {
    final page = profileType == UserType.manager
        ? const ManagerSignupScreen()
        : const DeliverySignupScreen();

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
