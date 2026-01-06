import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String deliveryCode = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryCode();
  }

  Future<void> _fetchDeliveryCode() async {
    final uid = AuthService().currentUserId;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('delivery_boys') // ✅ CORRECT COLLECTION
          .doc(uid)
          .get();

      if (!doc.exists) {
        setState(() {
          deliveryCode = 'No code assigned';
          isLoading = false;
        });
        return;
      }

      setState(() {
        deliveryCode = doc.data()?['deliveryCode'] ?? 'No code assigned';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        deliveryCode = 'Error fetching code';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AuthService().signOut();
          if (mounted) Navigator.pop(context);
        },
        child: const Icon(Icons.logout),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                'Delivery Code: $deliveryCode',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
