import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AuthService().signOut();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
        child: Icon(Icons.logout),
      ),
      body: Center(child: Text("Settings")),
    );
  }
}
