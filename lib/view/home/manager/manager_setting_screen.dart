import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:flutter/material.dart';

class ManagerSettingScreen extends StatefulWidget {
  const ManagerSettingScreen({super.key});

  @override
  State<ManagerSettingScreen> createState() => _ManagerSettingScreenState();
}

class _ManagerSettingScreenState extends State<ManagerSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AuthService().signOut();
          Navigator.of(context).pop();
        },
        child: Icon(Icons.logout),
      ),
      body: Center(child: Text("Settings")),
    );
  }
}
