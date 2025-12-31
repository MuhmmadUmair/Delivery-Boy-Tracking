import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/home/user/user_map_screen.dart';
import 'package:firebase_google_apple_notif/view/profile/user/user_profile.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;

  final AuthService _authService = AuthService();
  User? _currentUser;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  final Connectivity _connectivity = Connectivity();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    // Initialize pages
    _pages = [
      _DashboardPage(isOnline: _isOnline),
      const Center(child: Text("Map Page")),
      const Center(child: Text("History Page")),
      const UserProfile(),
    ];

    // Listen to connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      // Consider the device online if any connection is available
      bool isConnected = results.any((r) => r != ConnectivityResult.none);

      setState(() {
        _isOnline = isConnected;
        _pages[0] = _DashboardPage(isOnline: _isOnline);
      });

      if (_currentUser != null) {
        if (isConnected) {
          await _authService.setDeliveryBoyStatus(_currentUser!.uid, 'idle');
        } else {
          await _authService.setDeliveryBoyStatus(_currentUser!.uid, 'offline');
        }
      }
    });

    // Ensure onDisconnect is set to offline for app termination
    if (_currentUser != null) {
      final statusRef = FirebaseDatabase.instance.ref(
        'delivery_boys/${_currentUser!.uid}/status',
      );
      statusRef.onDisconnect().set('offline');
    }
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ===================== DASHBOARD PAGE =====================
class _DashboardPage extends StatelessWidget {
  final bool isOnline;

  const _DashboardPage({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildProfileHeader(),
            _buildHeroCard(context),
            _buildStatsGrid(),
            _buildRecentActivityHeader(),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  // ======= TOP APP BAR =======
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            child: const Icon(Icons.menu, size: 28),
          ),
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Icon(Icons.notifications, size: 28),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======= PROFILE HEADER =======
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBGLFkUbp7qKxomI6bsGsoDjSymefB1v4h9w78aCNQ56qPapbWarijOYqk_qqZWI893yZrrc3KOONcEOIWjLGORtaDXaD33LECNPo5QmydElC7D2C37c0laSPFUXP3qXbUoLNovzapGChykqbApih7tjfTvUKtNEN2yAk4Kt2lgacjiBNCnPxNkUlX5QXtuI3bnnepuMH4q9Wkxv8jCPg_5-FZ12X_mPEhj5mfr_0oMtSslqeiN-K8eHMtBk-wdR-cgqFOov3yj15A',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Hello, Alex",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Delivery Partner",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
              border: isOnline
                  ? Border.all(color: Colors.green.withOpacity(0.2))
                  : Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 6,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======= HERO CARD =======
  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserMapScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 128,
        decoration: BoxDecoration(
          color: const Color(0xFF192233),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            "Tap to open Map",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ======= STATS GRID =======
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(Icons.schedule, "Duration", "6h 12m"),
          _buildStatCard(Icons.local_shipping, "Stops", "18"),
          _buildStatCard(Icons.timer_off, "Stop Time", "45m"),
          _buildStatCard(Icons.verified, "Success", "98%", color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232F48),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ======= RECENT ACTIVITY =======
  Widget _buildRecentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Recent Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("See All", style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActivityItem(
            icon: Icons.inventory,
            title: "Order #4922",
            subtitle: "123 Main St, Downtown",
            time: "14:30",
            status: "Done",
            statusColor: Colors.green,
          ),
          _buildActivityItem(
            icon: Icons.local_mall,
            title: "Pickup #4923",
            subtitle: "Starbucks, 5th Ave",
            time: "15:00",
            status: "Picked",
            statusColor: Colors.orange,
          ),
          _buildActivityItem(
            icon: Icons.inventory,
            title: "Order #4920",
            subtitle: "78 Broadway Ave",
            time: "13:15",
            status: "Done",
            statusColor: Colors.grey,
            opacity: 0.6,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required Color statusColor,
    double opacity = 1,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF192233),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: statusColor, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      status,
                      style: TextStyle(fontSize: 10, color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
