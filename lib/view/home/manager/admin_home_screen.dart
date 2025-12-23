import 'package:firebase_google_apple_notif/app/components/my_list_tile.dart';
import 'package:firebase_google_apple_notif/app/components/my_tile_bar.dart';
import 'package:firebase_google_apple_notif/model/admin_model.dart';
import 'package:firebase_google_apple_notif/repository/admin_repository.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/profile_type.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminRepository _repository = AdminRepository();

  late Future<List<AdminModel>> dashboardFuture;
  late Future<List<AdminModel>> activityFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = _repository.getDashboardCards();
    activityFuture = _repository.getRecentActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Welcome Admin',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.notifications_none, color: Colors.white),
                  const SizedBox(width: 10),

                  // Dropdown Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      // Handle menu item selection
                      if (value == 'Profile') {
                        // Navigate to profile page or perform an action
                      } else if (value == 'Settings') {
                        // Navigate to settings
                      } else if (value == 'Logout') {
                        // Logout logic
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Profile',
                        child: Text('Profile'),
                      ),
                      const PopupMenuItem(
                        value: 'Settings',
                        child: Text('Settings'),
                      ),
                      PopupMenuItem(
                        value: 'Logout',
                        onTap: () async {
                          await AuthService().signOut();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProfileTypeSelectionScreen(),
                            ),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                "Here's what's happening today",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 17),

              // Dashboard Cards
              SizedBox(
                height: 135,
                child: FutureBuilder<List<AdminModel>>(
                  future: dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data ?? [];

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: MyTileBar(
                            icon: data[index].icon,
                            num: data[index].count,
                            type: data[index].type,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Recent Activity Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recent Activity List
              Expanded(
                child: FutureBuilder<List<AdminModel>>(
                  future: activityFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data ?? [];

                    return ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return MyListTile(
                          nameTitle: data[index].nameTitle,
                          purpose: data[index].purpose,
                          location: data[index].location,
                          status: data[index].status,
                          date: data[index].date,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
