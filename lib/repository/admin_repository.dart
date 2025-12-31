import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get delivery boy by delivery code
  Future<DocumentSnapshot<Map<String, dynamic>>> getDeliveryBoy(
    String code,
  ) async {
    final query = await _firestore
        .collection('users')
        .where('deliveryCode', isEqualTo: code)
        .where('profileType', isEqualTo: UserType.delivery.name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception('Delivery boy not found');
    return query.docs.first;
  }

  /// Link delivery boy to manager
  Future<void> linkToManager(String deliveryBoyId, String managerId) async {
    await _firestore.collection('users').doc(deliveryBoyId).update({
      'managerId': managerId,
    });
  }
}
