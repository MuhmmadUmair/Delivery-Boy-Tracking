import 'package:firebase_google_apple_notif/model/admin_model.dart';
import 'package:firebase_google_apple_notif/model/patner_model.dart';
import 'package:firebase_google_apple_notif/model/query_model.dart';
import 'package:firebase_google_apple_notif/model/mock_admin_data.dart';

class AdminRepository {
  /// ================= Dashboard =================
  Future<List<AdminModel>> getDashboardCards() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return AdminMockData.dashboardCards;
  }

  /// ================= Recent Activities =================
  Future<List<AdminModel>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AdminMockData.recentActivities;
  }

  /// ================= Partners =================
  Future<List<PartnerModel>> getPartners() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AdminMockData.partners;
  }

  /// ================= Queries =================
  Future<List<QueryModel>> getQueries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AdminMockData.queries;
  }

  /// ================= Optional: Dashboard stats =================
  Future<List<Map<String, dynamic>>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'title': 'Queries', 'count': AdminMockData.queries.length},
      {'title': 'Partners', 'count': AdminMockData.partners.length},
      {'title': 'Employees', 'count': 25}, // example static data
      {'title': 'Deliveries', 'count': 12}, // example static data
    ];
  }

  /// ================= Optional: Recent Partner/Employee =================
  Future<List<Map<String, dynamic>>> getRecentPartner() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'name': 'Partner',
        'purpose': 'Home Renovation',
        'location': 'Dubai UAE',
        'status': 'Driver Accepted',
        'date': '12/10/2025',
      },
      {
        'name': 'Employee',
        'purpose': 'Office Task',
        'location': 'Lahore',
        'status': 'Completed',
        'date': '10/10/2025',
      },
    ];
  }
}
