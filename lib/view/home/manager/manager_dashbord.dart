import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:firebase_google_apple_notif/view/orders/manager/order_overview_screen.dart';
import 'package:firebase_google_apple_notif/view/home/manager/team_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_google_apple_notif/view/home/manager/add_delivery_boy.dart';
import 'package:firebase_google_apple_notif/view/profile/manager/manager_setting_screen.dart';
import 'package:firebase_google_apple_notif/view/map/manager/track_delivery_boy.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final ManagerService _managerService = ManagerService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: _currentIndex == 0
          ? _buildDashboard()
          : _currentIndex == 1
          ? const TrackDeliveryBoysScreen()
          : _currentIndex == 2
          ? const OrdersOverviewScreen()
          : const ManagerSettingsScreen(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF135BEC),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddDeliveryBoyScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ───────────── DASHBOARD ─────────────
  Widget _buildDashboard() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: StreamBuilder(
              stream: _managerService.getManagerStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final managerData = snapshot.data!.data();
                final deliveryBoyIds = List<String>.from(
                  managerData?['deliveryBoys'] ?? [],
                );

                if (deliveryBoyIds.isEmpty) {
                  return const Center(
                    child: Text(
                      'No delivery boys assigned yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // ───────────── REALTIME DATABASE STREAM ─────────────
                return StreamBuilder(
                  stream: _managerService.getDeliveryBoysRealtime(),
                  builder: (context, rtdbSnapshot) {
                    if (!rtdbSnapshot.hasData ||
                        rtdbSnapshot.data!.snapshot.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final rtdbData = Map<String, dynamic>.from(
                      rtdbSnapshot.data!.snapshot.value as Map,
                    );

                    return FutureBuilder(
                      future: _managerService.getDeliveryBoys(),
                      builder: (context, boysSnapshot) {
                        if (!boysSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // ───────────── MERGE FIRESTORE + RTDB ─────────────
                        final deliveryBoys = _managerService.mergeDeliveryBoys(
                          boysSnapshot.data as List<Map<String, dynamic>>,
                          rtdbData,
                        );

                        final stats = _managerService.calculateStats(
                          deliveryBoys,
                        );

                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 90),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMapCard(deliveryBoys),
                              _buildStatsRow(stats),
                              _buildTeamHeader(),
                              _buildTeamList(deliveryBoys),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── TOP BAR ─────────────
  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back",
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Test Manager",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF1C2333),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ───────────── MAP CARD ─────────────
  Widget _buildMapCard(List<Map<String, dynamic>> deliveryBoys) {
    final Set<Marker> markers = deliveryBoys
        .map((d) {
          final location = d['lastLocation'];
          if (location != null &&
              location['lat'] != null &&
              location['lng'] != null) {
            return Marker(
              markerId: MarkerId(d['uid']),
              position: LatLng(
                (location['lat'] as num).toDouble(),
                (location['lng'] as num).toDouble(),
              ),
              infoWindow: InfoWindow(title: d['name']),
            );
          }
          return null;
        })
        .whereType<Marker>()
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: TrackDeliveryBoysScreen.initialPosition,
                markers: markers,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrackDeliveryBoysScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── STATS ROW ─────────────
  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final totalDistance = (stats['totalDistance'] as num?)?.toDouble() ?? 0.0;

    final successRate = (stats['successRate'] as num?)?.toDouble() ?? 0.0;

    final active = stats['active'] ?? 0;
    final total = stats['total'] ?? 0;
    final offline = stats['offline'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            title: "Distance",
            value: totalDistance.toStringAsFixed(1),
            valueSuffix: " km",
            subtitle: "+12% vs yest.",
            icon: Icons.route,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: "Active",
            value: "$active",
            valueSuffix: "/$total",
            subtitle: "$offline offline",
            icon: Icons.local_shipping,
            color: Colors.orange,
          ),
          _buildStatCard(
            title: "Success",
            value: "${successRate.toStringAsFixed(0)}%",
            subtitle: "On target",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? valueSuffix,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (valueSuffix != null)
                  TextSpan(
                    text: valueSuffix,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    ),
  );

  // ───────────── TEAM LIST ─────────────
  Widget _buildTeamHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Team Status",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeamScreen()),
            );
          },
          child: const Text(
            "View All",
            style: TextStyle(color: Color(0xFF135BEC)),
          ),
        ),
      ],
    ),
  );

  Widget _buildTeamList(List<Map<String, dynamic>> teamList) {
    // Show only the first 3 users
    final displayList = teamList.length > 3 ? teamList.sublist(0, 3) : teamList;

    return Column(
      children: displayList.map((data) {
        final status = _managerService.getRealTimeStatus(data);
        return _buildTeamCard(
          name: data['name'] ?? 'Unknown',
          status: status.toUpperCase(),
          statusColor: _managerService.getStatusColor(status),
          lastSeen: data['createdAt'] != null && status == 'offline'
              ? _getLastSeen((data['createdAt'] as Timestamp).toDate())
              : null,
          address: data['address'] ?? '',
          isOffline: status == 'offline',
        );
      }).toList(),
    );
  }

  Widget _buildTeamCard({
    required String name,
    required String status,
    required Color statusColor,
    String? lastSeen,
    bool isOffline = false,
    String? address,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1C2333),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 10, color: statusColor),
                    ),
                  ),
                ],
              ),
              if ((lastSeen != null && lastSeen.isNotEmpty) ||
                  (address != null && address.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lastSeen != null)
                        Text(
                          lastSeen,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      if (address != null && address.isNotEmpty)
                        Text(
                          address,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Icon(
          isOffline ? Icons.call : Icons.my_location,
          color: isOffline ? Colors.grey : const Color(0xFF135BEC),
        ),
      ],
    ),
  );

  // ───────────── BOTTOM NAV ─────────────
  Widget _buildBottomNav() => BottomAppBar(
    color: const Color(0xFF1C2333),
    shape: const CircularNotchedRectangle(),
    notchMargin: 8,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.dashboard,
            color: _currentIndex == 0 ? const Color(0xFF135BEC) : Colors.grey,
          ),
          onPressed: () => setState(() => _currentIndex = 0),
        ),
        IconButton(
          icon: Icon(
            Icons.map,
            color: _currentIndex == 1 ? const Color(0xFF135BEC) : Colors.grey,
          ),
          onPressed: () => setState(() => _currentIndex = 1),
        ),
        _currentIndex == 0 ? const SizedBox(width: 40) : SizedBox.shrink(),
        IconButton(
          icon: Icon(
            Icons.list_alt_rounded,
            color: _currentIndex == 2 ? const Color(0xFF135BEC) : Colors.grey,
          ),
          onPressed: () => setState(() => _currentIndex = 2),
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: _currentIndex == 3 ? const Color(0xFF135BEC) : Colors.grey,
          ),
          onPressed: () => setState(() => _currentIndex = 3),
        ),
      ],
    ),
  );

  // ───────────── LAST SEEN HELPER ─────────────
  String _getLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    int hour = dateTime.hour % 12;
    if (hour == 0) hour = 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final time = "$hour:$minute $amPm";

    if (dateTime.isAfter(today)) return "Last seen today at $time";
    if (dateTime.isAfter(yesterday)) return "Last seen yesterday at $time";
    return "Last seen on ${dateTime.day} ${_monthName(dateTime.month)}, $time";
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
