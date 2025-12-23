import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';

import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/data/response/api_response.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  /* ---------------------------------------------------- */
  /* CREATE ACCOUNT */
  /* ---------------------------------------------------- */

  Future<ApiResponse<User>> createAccount({
    required String email,
    required String password,
    required String name,
    required UserType profileType,
    String? phone,
    String? address,
    String? profilePicUrl,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FetchDataException('User creation failed');
      }

      await _saveUserData(
        uid: credential.user!.uid,
        name: name,
        email: email,
        profileType: profileType,
        phone: phone,
        address: address,
        profileUrl: profilePicUrl,
      );

      return ApiResponse.completed(credential.user!);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapFirebaseAuthError(e).userMessage);
    } catch (e) {
      return ApiResponse.error(
        e is AppException ? e.userMessage : 'Something went wrong',
      );
    }
  }

  /* ---------------------------------------------------- */
  /* LOGIN */
  /* ---------------------------------------------------- */

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

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw UnauthorizedException('User data not found');
      }

      if (doc.data()?['profileType'] != profileType.name) {
        await signOut();
        throw UnauthorizedException('Invalid user role');
      }

      return ApiResponse.completed(credential.user!);
    } on FirebaseAuthException catch (e) {
      return ApiResponse.error(_mapFirebaseAuthError(e).userMessage);
    } catch (e) {
      return ApiResponse.error(
        e is AppException ? e.userMessage : 'Something went wrong',
      );
    }
  }

  /* ---------------------------------------------------- */
  /* GOOGLE SIGN IN */
  /* ---------------------------------------------------- */

  Future<ApiResponse<User>> signInWithGoogle({
    required UserType profileType,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw InvalidInputException('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _auth.signInWithCredential(credential);

      final doc = await _firestore
          .collection('users')
          .doc(authResult.user!.uid)
          .get();

      if (!doc.exists) {
        await _saveUserData(
          uid: authResult.user!.uid,
          name: authResult.user!.displayName ?? '',
          email: authResult.user!.email ?? '',
          profileType: profileType,
        );
      } else if (doc.data()?['profileType'] != profileType.name) {
        await signOut();
        throw UnauthorizedException('Invalid user role');
      }

      return ApiResponse.completed(authResult.user!);
    } catch (e) {
      return ApiResponse.error(
        e is AppException ? e.userMessage : 'Something went wrong',
      );
    }
  }

  /* ---------------------------------------------------- */
  /* SIGN OUT */
  /* ---------------------------------------------------- */

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /* ---------------------------------------------------- */
  /* SAVE USER DATA */
  /* ---------------------------------------------------- */

  Future<void> _saveUserData({
    required String uid,
    required String name,
    required String email,
    required UserType profileType,
    String? phone,
    String? address,
    String? profileUrl,
  }) async {
    Map<String, dynamic>? location;

    try {
      final position = await Geolocator.getCurrentPosition();
      location = {'lat': position.latitude, 'lng': position.longitude};
    } catch (e) {
      log('Location unavailable: $e');
      // It's okay, we save user without location
    }

    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'profileType': profileType.name,
        'profileUrl': profileUrl ?? '',
        'phone': phone ?? '',
        'address': address ?? '',
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
      log('User saved in Firestore: $uid');
    } catch (e) {
      log('Error saving user in Firestore: $e');
      throw Exception('Failed to save user data');
    }
  }

  /* ---------------------------------------------------- */
  /* ERROR MAPPER */
  /* ---------------------------------------------------- */

  AppException _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UnauthorizedException('User not found');
      case 'wrong-password':
        return UnauthorizedException('Incorrect password');
      case 'email-already-in-use':
        return BadRequestException('Email already in use');
      case 'invalid-email':
        return InvalidInputException('Invalid email address');
      case 'weak-password':
        return InvalidInputException('Password too weak');
      default:
        return FetchDataException(e.message);
    }
  }
}
