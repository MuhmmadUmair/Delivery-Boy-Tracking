import 'package:flutter/material.dart';

class AdminModel {
  // Dashboard cards
  final IconData icon;
  final String count;
  final String type;

  // Recent activity
  final String nameTitle;
  final String purpose;
  final String location;
  final String status;
  final String date;

  AdminModel({
    required this.icon,
    required this.count,
    required this.type,
    required this.nameTitle,
    required this.purpose,
    required this.location,
    required this.status,
    required this.date,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      icon: Icons.copy, // icon usually comes from frontend
      count: json['count'] ?? '',
      type: json['type'] ?? '',
      nameTitle: json['nameTitle'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
