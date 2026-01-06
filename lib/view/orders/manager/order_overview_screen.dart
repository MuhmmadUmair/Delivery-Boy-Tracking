import 'package:firebase_google_apple_notif/view/orders/manager/assign_task.dart';
import 'package:firebase_google_apple_notif/view/orders/manager/order_detail_screen.dart';
import 'package:flutter/material.dart';

class OrdersOverviewScreen extends StatelessWidget {
  const OrdersOverviewScreen({super.key});

  // ======= Sample Stats List =======
  final List<Map<String, dynamic>> stats = const [
    {
      'icon': Icons.local_shipping,
      'iconBg': Color(0x1A135BEC),
      'iconColor': Colors.white,
      'title': 'Active Orders',
      'value': '12',
      'trendValue': '+12%',
      'trendColor': Colors.green,
    },
    {
      'icon': Icons.sports_motorsports,
      'iconBg': Color(0x1AFF9800),
      'iconColor': Colors.white,
      'title': 'Available Riders',
      'value': '4',
      'trendValue': '4/16',
      'trendColor': Colors.grey,
    },
  ];

  // ======= Sample Orders List =======
  final List<Map<String, dynamic>> orders = const [
    {
      'id': '2045',
      'time': '10:45 AM • Today',
      'status': 'In Progress',
      'statusColor': Color(0xFF135BEC),
      'riderName': 'Michael B.',
      'distance': '2.4km away • to 123 Main St',
      'riderImage':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBv1UyxsuOyaXVNCVHaY4640nd5-uHNACwxKYGKN1C0ClQczP7tZGly4MkWI8vmYb43cFTQy-mAGIKs1psz9Lwzs-oXU3VWbXPGorXRmDTRkHVNX5osw70XgXoZhLwICAEGFacmcZD1N5e48We1aRRfXRkEMFhzrNBRPV-MaDLIVntbfZtweVeM-NEStkJU6r7forIAr6JFsrNUh7EuXRESEgAJgc6y1fDAIYv7qif5P3jJF_2A8rg_opZmDIx_hDSv_Vo72U-rxKo',
      'icon': Icons.directions_bike,
    },
    {
      'id': '2046',
      'time': '11:15 AM • Today',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'riderName': 'Unassigned',
      'distance': 'Pickup: Downtown Market',
      'riderImage': null,
      'icon': Icons.person_add,
    },
    {
      'id': '2042',
      'time': '09:30 AM • Today',
      'status': 'In Progress',
      'statusColor': Color(0xFF135BEC),
      'riderName': 'Sarah J.',
      'distance': '0.8km away • to 45 Park Ave',
      'riderImage':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAG3oSz9aZezzTBNufMXnWQcYcUjEI7C_USg9AORexlVetke4e1xIWYACzv0JrRHDaOofXKsSAcBf0Zw4b2IAHz_fD7KBuX9x1p7lUyc481Ld43P7PokzIIFEzT0OaCqfJWwNQdPb94MGAgliEnEt7JVYGd_zdnU-RvIenVyQI5nbBS4ea_Hpl1C8sN9MBnfJ21F_IjgsZ9KnX9W-66L4G_DI2wrOFvg-JZWozAnct88iPjHXpXAeLlg1oUmcANxW9Ec4GrecrcZRw',
      'icon': Icons.moped,
    },
    {
      'id': '2040',
      'time': '08:15 AM • Today',
      'status': 'Completed',
      'statusColor': Colors.green,
      'riderName': 'David C.',
      'distance': 'Delivered to Westside Apts',
      'riderImage':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD08lsVtz7IzaUdtpVoa77kE59gAYuziOLn-gSMHRuVVt4Mu6k95Ii6UTY9-YzKvJLDoiywOHpRBF2EUrVMZoKB2rlXcSOjd8gpTrDU5rhNJ-Dm4A86FSXS-kdTgQuxw3T0TBdyGTUOTrbWUABZjPnC1LubQd2OBsxCmUE3JIS0eNh-4TV56tPSwqeYUy0vY8czzjdqhwTA_xGndrF7r6amQlUEE-LiXsdvKiTCmk30Nf7T27M8F0pp9pFdiyx7pOHcf7M5lCLY_0Q',
      'icon': Icons.check_circle,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622), // dark background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCZklykPMk7b3_Wutq65PkBnpda-X_jHbp87n7WhWNAmEfNTWohxQcTQFN1UA3lkVDcbY60UPXLaDEz1GEJPHKzPzWs61qOgyoq3DggaGZFneoQspfyFNiUhjLxjadTq-CD4EIGvigtxggKk5iWRbjOzTFhs1vG6A5q9ZG-iry9fz2UBS1M4pbriEx73YLf8Bai5dc6d4uwMqdBBMx3M_P-gZDFCNcpYgYBvwZQ5xO5rkpE7t8NDoNS0LtQxSaiVPOclRTvorX-Uuk',
                                ),
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Orders",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Tuesday, 24 Oct",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Cards
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: stats.length,
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StatsCardDark(stat: stat),
                      );
                    },
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      hintText: "Search Order ID, Rider...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF232F48),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF135BEC),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Orders List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCardDark(order: order);
                    },
                  ),
                ),
              ],
            ),

            // Floating Button
            Positioned(
              bottom: 30,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF135BEC),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AssignTaskScreen()),
                  );
                },
                label: const Text(
                  "Assign Task",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Stats Card Dark =======
class StatsCardDark extends StatelessWidget {
  final Map<String, dynamic> stat;
  const StatsCardDark({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF232F48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: stat['iconBg'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'], color: Colors.white, size: 20),
              ),
              Text(
                stat['trendValue'],
                style: TextStyle(
                  color: stat['trendColor'],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat['title'],
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            stat['value'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Order Card Dark =======
class OrderCardDark extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderCardDark({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2230),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF232F48)),
        ),
        child: Column(
          children: [
            // Top Row: Order ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order['id']}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: order['statusColor'],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['time'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: order['statusColor'].withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(color: order['statusColor'], fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rider info
            Row(
              children: [
                if (order['riderImage'] != null)
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(order['riderImage']),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[700],
                    child: Icon(order['icon'], color: Colors.white),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['riderName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: order['riderName'] == "Unassigned"
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['distance'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order['riderName'] == "Unassigned")
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF135BEC),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Assign",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
