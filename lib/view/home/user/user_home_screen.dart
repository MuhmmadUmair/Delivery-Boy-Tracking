import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_google_apple_notif/services/delivery_serivce.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_google_apple_notif/view/map/user/track_order_screen.dart';
import 'package:firebase_google_apple_notif/view/profile/user/user_profile.dart';

/// ================= DELIVERY DASHBOARD SCREEN =================
class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;

  final DeliveryService _deliveryService = DeliveryService();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  late StreamSubscription<bool> _onlineStatusSub;
  final Connectivity _connectivity = Connectivity();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initPages();
    _initDeliveryService();
    _initConnectivityListener();
    _initOnlineStatusListener();
  }

  void _initPages() {
    _pages = [
      _DashboardPage(isOnline: _isOnline, deliveryService: _deliveryService),
      const UserMapScreen(),
      const Center(
        child: Text("History Page", style: TextStyle(color: Colors.white)),
      ),
      const UserProfile(),
    ];
  }

  void _initDeliveryService() async {
    _deliveryService.init();
    await _deliveryService.createDeliveryBoyIfNotExists();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _deliveryService.setOnlineAndStartHeartbeat(user.uid);
    }
  }

  void _initConnectivityListener() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
          _updatePages();
        });
      }
    });
  }

  void _initOnlineStatusListener() {
    _onlineStatusSub = _deliveryService.onlineStatusStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          _updatePages();
        });
      }
    });
  }

  void _updatePages() {
    _pages[0] = _DashboardPage(
      isOnline: _isOnline,
      deliveryService: _deliveryService,
    );
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    _onlineStatusSub.cancel();
    _deliveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF161E2E),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

/// ================= DASHBOARD PAGE =================
class _DashboardPage extends StatelessWidget {
  final bool isOnline;
  final DeliveryService deliveryService;

  const _DashboardPage({required this.isOnline, required this.deliveryService});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildProfileHeader(isOnline, user),
            _buildHeroCard(context),
            _buildStatsGrid(user!.uid),
            _buildRecentActivityHeader(),
            _buildRecentActivityList(user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, size: 28, color: Colors.white),
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildProfileHeader(bool isOnline, User? user) {
    final displayName =
        user?.displayName ?? user?.email?.split('@').first ?? "Delivery Boy";

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
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          user?.photoURL ??
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=135BEC&color=fff',
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
                children: [
                  Text(
                    "Hello, $displayName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
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

  Widget _buildHeroCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserMapScreen()),
      ),
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

  Widget _buildStatsGrid(String uid) {
    return FutureBuilder<Map<String, dynamic>>(
      future: deliveryService.computeOrderStats(uid),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ??
            {'totalOrders': 0, 'completedOrders': 0, 'successRate': '0%'};

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
              _buildStatCard(
                Icons.local_shipping,
                "Total Orders",
                "${stats['totalOrders']}",
              ),
              _buildStatCard(
                Icons.check_circle,
                "Completed",
                "${stats['completedOrders']}",
              ),
              _buildStatCard(
                Icons.timer,
                "Pending",
                "${stats['totalOrders'] - stats['completedOrders']}",
              ),
              _buildStatCard(
                Icons.verified,
                "Success",
                stats['successRate'],
                color: Colors.green,
              ),
            ],
          ),
        );
      },
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
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildRecentActivityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text("See All", style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(String deliveryBoyId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: deliveryService.streamOrders(deliveryBoyId: deliveryBoyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Failed to load orders",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: const [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Your assigned orders will appear here",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: orders.map((order) => _buildOrderItem(order)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final customerName = order['customerName'] ?? "Unknown";
    final customerPhone = order['customerPhone'] ?? "N/A";
    final description = order['description'] ?? "No description";
    final pickup = order['pickup'];
    final drop = order['drop'];
    final status = order['status'] ?? "assigned";
    final orderId = order['orderId'] ?? "";

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'assigned':
        statusColor = Colors.blue;
        statusIcon = Icons.assignment;
        break;
      case 'picked':
        statusColor = Colors.orange;
        statusIcon = Icons.local_shipping;
        break;
      case 'done':
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF192233),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Text(
                  "#${orderId.substring(0, 8)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      customerPhone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                if (pickup != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Pickup: ${pickup['lat']?.toStringAsFixed(4)}, ${pickup['lng']?.toStringAsFixed(4)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (drop != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Drop: ${drop['lat']?.toStringAsFixed(4)}, ${drop['lng']?.toStringAsFixed(4)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
