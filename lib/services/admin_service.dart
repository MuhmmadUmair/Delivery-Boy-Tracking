import 'package:firebase_google_apple_notif/model/admin_model.dart';
import 'package:firebase_google_apple_notif/model/patner_model.dart';
import 'package:firebase_google_apple_notif/model/query_model.dart';
import 'package:firebase_google_apple_notif/repository/admin_repository.dart';
import 'package:flutter/material.dart';

class AdminService {
  final AdminRepository _repo = AdminRepository();

  /// ================= Dashboard =================
  Future<List<AdminModel>> fetchAdminDashboard() async {
    // Uncomment below to use real API later
    // final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    // if (response.statusCode == 200) { ... }
    return _repo.getDashboardCards();
  }

  /// ================= Recent Activities =================
  Future<List<AdminModel>> fetchRecentActivity() async {
    return _repo.getRecentActivities();
  }

  /// ================= Partners =================
  Future<List<PartnerModel>> fetchPartners(BuildContext context) async {
    return _repo.getPartners();
  }

  /// ================= Queries =================
  Future<List<QueryModel>> fetchQueries() async {
    return _repo.getQueries();
  }

  /// ================= Optional Dashboard stats =================
  Future<List<Map<String, dynamic>>> fetchDashboardStats() async {
    return _repo.getDashboardStats();
  }

  /// ================= Optional Recent Partner =================
  Future<List<Map<String, dynamic>>> fetchRecentPartner() async {
    return _repo.getRecentPartner();
  }
}
