import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_google_apple_notif/view/home/manager/add_delivery_boy.dart';
import 'package:firebase_google_apple_notif/view/home/manager/manager_setting_screen.dart';
import 'package:firebase_google_apple_notif/view/home/manager/track_delivery_boy.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    TrackDeliveryBoysScreen(),
    ManagerSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: _pages[_currentIndex],
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

  Widget _buildBottomNav() => BottomAppBar(
    color: const Color(0xFF1C2333),
    shape: const CircularNotchedRectangle(),
    notchMargin: 8,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const SizedBox(width: 40), // Space for FAB
          IconButton(
            icon: Icon(
              Icons.settings,
              color: _currentIndex == 2 ? const Color(0xFF135BEC) : Colors.grey,
            ),
            onPressed: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    ),
  );
}

// ───────────── DASHBOARD CONTENT ─────────────
class DashboardContent extends StatelessWidget {
  DashboardContent({super.key});

  static const managerUid = "VHKCoMWZeGbb4MDaabLJYslxztp2";
  final DatabaseReference rtdbRef = FirebaseDatabase.instance.ref(
    'delivery_boys',
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('managers')
                  .doc(managerUid)
                  .snapshots(),
              builder: (context, managerSnapshot) {
                if (!managerSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final managerData =
                    managerSnapshot.data!.data() as Map<String, dynamic>?;

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

                // ───────────── STREAM FROM REALTIME DATABASE ─────────────
                return StreamBuilder<DatabaseEvent>(
                  stream: rtdbRef.onValue,
                  builder: (context, rtdbSnapshot) {
                    if (!rtdbSnapshot.hasData ||
                        rtdbSnapshot.data!.snapshot.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final rtdbData = Map<String, dynamic>.from(
                      (rtdbSnapshot.data!.snapshot.value as Map),
                    );

                    // ───────────── MERGE WITH FIRESTORE DATA ─────────────
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('delivery_boys')
                          .where('uid', whereIn: deliveryBoyIds)
                          .snapshots(),
                      builder: (context, boysSnapshot) {
                        if (!boysSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final deliveryBoys = boysSnapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final uid = data['uid'];

                          final rtdbBoy =
                              rtdbData[uid] as Map<dynamic, dynamic>?;

                          return {
                            'uid': uid,
                            'name': data['name'] ?? 'Unknown',
                            'address': data['address'] ?? '',
                            'createdAt': data['createdAt'],
                            'success': data['success'] ?? false,
                            'status': rtdbBoy != null
                                ? rtdbBoy['status'] ?? 'offline'
                                : 'offline',
                            'lastStatusUpdate': rtdbBoy != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    rtdbBoy['lastUpdated'],
                                  )
                                : null,
                            'lastLocation': rtdbBoy != null
                                ? rtdbBoy['location']
                                : null,
                            'distance': (data['stats']?['totalDistance'] ?? 0)
                                .toDouble(),
                          };
                        }).toList();

                        final stats = _calculateStats(deliveryBoys);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 90),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMapCard(deliveryBoys, context),
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
  Widget _buildMapCard(
    List<Map<String, dynamic>> deliveryBoys,
    BuildContext context,
  ) {
    final Set<Marker> markers = deliveryBoys
        .map((d) {
          final location = d['lastLocation'];
          if (location != null &&
              location['lat'] != null &&
              location['lng'] != null) {
            return Marker(
              markerId: MarkerId(d['uid']),
              position: LatLng(location['lat'], location['lng']),
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
              /// 🗺 MAP PREVIEW (NON-INTERACTIVE)
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

              /// 👉 TAP ANYWHERE → OPEN FULL MAP SCREEN
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

              /// 📍 LEFT BOTTOM → ACTIVE ZONE
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF135BEC),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "DHA Phase 6",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🧭 RIGHT BOTTOM → NAVIGATION ICON (VISUAL ONLY)
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackDeliveryBoysScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF135BEC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── STATS ─────────────
  Widget _buildStatsRow(Map<String, dynamic> stats) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        _buildStatCard(
          title: "Distance",
          value: stats['totalDistance'].toStringAsFixed(1),
          valueSuffix: " km",
          subtitle: "+12% vs yest.",
          icon: Icons.route,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: "Active",
          value: "${stats['active']}",
          valueSuffix: "/${stats['total']}",
          subtitle: "${stats['offline']} offline",
          icon: Icons.local_shipping,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: "Success",
          value: "${stats['successRate'].toStringAsFixed(0)}%",
          subtitle: "On target",
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    ),
  );

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

  // ───────────── TEAM ─────────────
  Widget _buildTeamHeader() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Team Status",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text("View All", style: TextStyle(color: Color(0xFF135BEC))),
      ],
    ),
  );

  Widget _buildTeamList(List<Map<String, dynamic>> teamList) => Column(
    children: teamList.map((data) {
      final status = _getRealTimeStatus(data);
      return _buildTeamCard(
        name: data['name'] ?? 'Unknown',
        status: status.toUpperCase(),
        statusColor: _getStatusColor(status),
        lastSeen: data['createdAt'] != null && status == 'offline'
            ? _getLastSeen((data['createdAt'] as Timestamp).toDate())
            : null,
        address: data['address'] ?? '',
        isOffline: status == 'offline',
      );
    }).toList(),
  );

  /// ───────────── Calculate real-time status ─────────────
  String _getRealTimeStatus(Map<String, dynamic> data) {
    final lastUpdate = data['lastStatusUpdate'] as DateTime?;
    final now = DateTime.now();

    if (lastUpdate == null) return 'offline';

    final diff = now.difference(lastUpdate).inSeconds;

    if (diff > 60) return 'offline'; // mark offline if no update > 60 sec
    return (data['status'] ?? 'idle').toLowerCase();
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

  // ───────────── STATS HELPERS ─────────────
  Map<String, dynamic> _calculateStats(
    List<Map<String, dynamic>> deliveryBoys,
  ) {
    int total = deliveryBoys.length;
    int active = deliveryBoys.where((d) {
      final status = _getRealTimeStatus(d);
      return status == 'moving' || status == 'idle';
    }).length;
    int offline = total - active;

    double totalDistance = 0;
    int successCount = 0;

    for (var d in deliveryBoys) {
      totalDistance += (d['distance'] ?? 0);
      if (d['success'] == true) successCount++;
    }

    double successRate = total > 0 ? (successCount / total) * 100 : 0;

    return {
      'total': total,
      'active': active,
      'offline': offline,
      'totalDistance': totalDistance,
      'successRate': successRate,
    };
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'moving':
        return Colors.green;
      case 'idle':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

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
