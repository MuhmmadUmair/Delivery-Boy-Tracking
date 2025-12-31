import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_google_apple_notif/repository/admin_repository.dart';
import 'package:flutter/material.dart';

class AdminService {
  final AdminRepository _repo = AdminRepository();

  /// Link delivery boy using delivery code (auto detect manager ID)
  Future<void> linkDeliveryBoy({
    required String deliveryCode,
    required BuildContext context,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Manager not logged in');
      }

      final managerId = currentUser.uid;

      final doc = await _repo.getDeliveryBoy(deliveryCode);

      await _repo.linkToManager(doc.id, managerId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery boy linked successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
