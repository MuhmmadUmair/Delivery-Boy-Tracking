import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.black,
      indicatorColor: Colors.amber,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard),
          selectedIcon: Icon(Icons.dashboard, color: Colors.white),
          label: 'Dashbord',
        ),
        NavigationDestination(
          icon: Icon(Icons.note_alt_rounded),
          selectedIcon: Icon(Icons.note_alt_rounded, color: Colors.white),
          label: 'Queries',
        ),
        NavigationDestination(
          icon: Icon(Icons.handshake),
          selectedIcon: Icon(Icons.handshake, color: Colors.white),
          label: 'Partners',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_sharp),
          selectedIcon: Icon(Icons.people_sharp, color: Colors.white),
          label: 'Employees',
        ),
      ],
    );
  }
}
