import 'package:firebase_google_apple_notif/model/admin_model.dart';
import 'package:firebase_google_apple_notif/model/patner_model.dart';
import 'package:firebase_google_apple_notif/model/query_model.dart';
import 'package:flutter/material.dart';

class AdminMockData {
  /// ================= Dashboard Cards =================
  static List<AdminModel> dashboardCards = [
    AdminModel(
      icon: Icons.copy,
      count: '15',
      type: 'Queries',
      nameTitle: '',
      purpose: '',
      location: '',
      status: '',
      date: '',
    ),
    AdminModel(
      icon: Icons.handshake,
      count: '08',
      type: 'Partners',
      nameTitle: '',
      purpose: '',
      location: '',
      status: '',
      date: '',
    ),
    AdminModel(
      icon: Icons.people,
      count: '25',
      type: 'Employees',
      nameTitle: '',
      purpose: '',
      location: '',
      status: '',
      date: '',
    ),
    AdminModel(
      icon: Icons.delivery_dining,
      count: '12',
      type: 'Deliveries',
      nameTitle: '',
      purpose: '',
      location: '',
      status: '',
      date: '',
    ),
  ];

  /// ================= Recent Activities =================
  static List<AdminModel> recentActivities = [
    AdminModel(
      icon: Icons.copy,
      count: '',
      type: '',
      nameTitle: 'Partner',
      purpose: 'Home Renovation',
      location: 'Dubai, UAE',
      status: 'Driver Accepted',
      date: '12/10/2025',
    ),
    AdminModel(
      icon: Icons.copy,
      count: '',
      type: '',
      nameTitle: 'Customer',
      purpose: 'AC Installation',
      location: 'Abu Dhabi, UAE',
      status: 'In Progress',
      date: '11/10/2025',
    ),
    AdminModel(
      icon: Icons.copy,
      count: '',
      type: '',
      nameTitle: 'Partner',
      purpose: 'Plumbing Work',
      location: 'Sharjah, UAE',
      status: 'Completed',
      date: '10/10/2025',
    ),
    AdminModel(
      icon: Icons.copy,
      count: '',
      type: '',
      nameTitle: 'Vendor',
      purpose: 'Electrical Repair',
      location: 'Ajman, UAE',
      status: 'Pending',
      date: '09/10/2025',
    ),
    AdminModel(
      icon: Icons.copy,
      count: '',
      type: '',
      nameTitle: 'Partner',
      purpose: 'Painting Work',
      location: 'Dubai, UAE',
      status: 'Driver Assigned',
      date: '08/10/2025',
    ),
  ];

  /// ================= Partners =================
  static List<PartnerModel> partners = [
    PartnerModel(
      name: "Muhammad Umair",
      company: "Crew Innovation",
      email: "muhhmadumair1@gmail.com",
      phone: "+923161688681",
      location: "Dubai UAE",
      status: "APPROVED",
      appliedDate: "04/12/2025",
    ),
    PartnerModel(
      name: "Ali Khan",
      company: "Tech Solutions",
      email: "alikhan@example.com",
      phone: "+923001234567",
      location: "Abu Dhabi UAE",
      status: "PENDING",
      appliedDate: "10/12/2025",
    ),
  ];

  /// ================= Queries =================
  static List<QueryModel> queries = [
    QueryModel(
      nameTitle: 'Partner',
      purpose: 'AC Repair',
      location: 'Dubai UAE',
      createdAt: 'Created: 4 days ago',
      status: 'Driver Assigned',
    ),
    QueryModel(
      nameTitle: 'Customer',
      purpose: 'Home Renovation',
      location: 'Abu Dhabi UAE',
      createdAt: 'Created: 2 days ago',
      status: 'Pending',
    ),
    QueryModel(
      nameTitle: 'Partner',
      purpose: 'Plumbing Work',
      location: 'Sharjah UAE',
      createdAt: 'Created: 5 days ago',
      status: 'Driver Accepted',
    ),
    QueryModel(
      nameTitle: 'Vendor',
      purpose: 'Electrical Repair',
      location: 'Ajman UAE',
      createdAt: 'Created: 1 week ago',
      status: 'Completed',
    ),
    QueryModel(
      nameTitle: 'Partner',
      purpose: 'Painting Work',
      location: 'Dubai UAE',
      createdAt: 'Created: 3 days ago',
      status: 'Driver Assigned',
    ),
  ];
}
