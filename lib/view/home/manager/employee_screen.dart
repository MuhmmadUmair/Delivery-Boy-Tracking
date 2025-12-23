import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      appBar: AppBar(
        backgroundColor: const Color(0xff2A2A2A),
        title: const Text('Employees', style: TextStyle(color: Colors.amber)),
      ),
      body: const Center(
        child: Text('Employees Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
