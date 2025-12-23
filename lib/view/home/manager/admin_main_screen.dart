import 'package:firebase_google_apple_notif/app/components/my_navigation_bar.dart';
import 'package:firebase_google_apple_notif/view/home/manager/employee_screen.dart';
import 'package:firebase_google_apple_notif/view/home/manager/manage_partens_screen.dart';
import 'package:flutter/material.dart';
import 'admin_home_screen.dart';
import 'quries_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminHomeScreen(), // Dashboard
    QuriesScreen(), // Queries
    ManagePartensScreen(), // Partners
    EmployeesScreen(), // Employees
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: MyNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
