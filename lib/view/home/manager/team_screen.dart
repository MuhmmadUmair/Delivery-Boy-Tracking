import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:flutter/material.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final ManagerService _managerService = ManagerService();
  // final String _managerUid = "VHKCoMWZeGbb4MDaabLJYslxztp2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2333),
        title: const Text("Team Status", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Listen manager's delivery boys list
        stream: _managerService.getManagerStream(),
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
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          }

          // Listen live Realtime Database + Firestore for delivery boys
          return StreamBuilder(
            stream: _managerService.getDeliveryBoysRealtime(),
            builder: (context, rtdbSnapshot) {
              if (!rtdbSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // --- Convert RTDB Map<dynamic,dynamic> -> Map<String,dynamic>
              final rawData =
                  rtdbSnapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
              final rtdbData = rawData != null
                  ? rawData.map((key, value) => MapEntry(key.toString(), value))
                  : <String, dynamic>{};

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _managerService.getDeliveryBoys(),
                builder: (context, boysSnapshot) {
                  if (!boysSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final deliveryBoys = boysSnapshot.data!;
                  // Merge Firestore + RTDB data
                  final mergedBoys = _managerService.mergeDeliveryBoys(
                    deliveryBoys,
                    rtdbData,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mergedBoys.length,
                    itemBuilder: (context, index) {
                      final data = mergedBoys[index];
                      final status = _managerService.getRealTimeStatus(data);

                      return _buildTeamCard(
                        name: data['name'] ?? 'Unknown',
                        status: status.toUpperCase(),
                        statusColor: _managerService.getStatusColor(status),
                        lastSeen:
                            (data['lastStatusUpdate'] != null &&
                                status == 'offline')
                            ? _getLastSeen(data['lastStatusUpdate'] as DateTime)
                            : null,
                        address: data['address'] ?? '',
                        isOffline: status == 'offline',
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Builds a single delivery boy card
  Widget _buildTeamCard({
    required String name,
    required String status,
    required Color statusColor,
    String? lastSeen,
    bool isOffline = false,
    String? address,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
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
              // Name + status
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
              // Last seen + address
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

  /// Returns human-readable "last seen" string
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
