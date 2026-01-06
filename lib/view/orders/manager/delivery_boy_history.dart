import 'package:flutter/material.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "id": "#ORD-3492",
        "date": "Oct 24, 2:30 PM",
        "status": "Completed",
        "statusColor": Colors.green,
        "pickup": "Joe's Burgers, 5th Ave",
        "dropoff": "1200 Market St, Apt 4B",
        "items": "2x Pizza, 1x Coke, 1x Fries",
        "price": "\$24.00",
      },
      {
        "id": "#ORD-3491",
        "date": "Oct 24, 11:15 AM",
        "status": "Completed",
        "statusColor": Colors.green,
        "pickup": "Pizza Hut, Downtown",
        "dropoff": "800 Broadway, Office 202",
        "items": "1x Large Peperoni, 2x Garlic Bread",
        "price": "\$32.50",
      },
      {
        "id": "#ORD-3488",
        "date": "Oct 23, 8:45 PM",
        "status": "Cancelled",
        "statusColor": Colors.red,
        "pickup": "Sushi Master",
        "dropoff": "45 Westside Dr",
        "items": "Customer cancelled order",
        "price": "\$18.00",
        "cancelled": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(
        0xFF101622,
      ), // Dark background like HTML code
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Center(
                      child: const Text(
                        "Order History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Profile Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuB1zgNagQLSSCQ6jKiiqNJipwM5RGfj16ikHkZXqUELnn-Rk5QKFtf-9_q9jj8eTkj7Vr_mQBw7ujv9x0M-GawJchSo1zMY9GI9GGdquyz6DbgLyGU6Yigq0diofzyL_dluPCtrqrhIn7s8ochx-hB53EBKqvXZ9Vwf9Dg6RkNyScjlH5NZwXWdGy3GGyLyFYJKmexDa1NA2vXMoxziuf0s9sPY1DGfTo-uP2uuUwUhoLFhscz4kKW83sDcUUVHirS0Rt1Y2iH8NOo",
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF101622),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Text(
                            "4.9",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                        "Alex Johnson",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 16,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "1,240 Total Orders",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatCard(
                    Icons.near_me,
                    "Distance",
                    "152 km",
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    Icons.payments,
                    "Earnings",
                    "\$420.50",
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.pie_chart, "Rate", "98%", Colors.purple),
                ],
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip("All Time", true),
                  _buildFilterChip("Today", false),
                  _buildFilterChip("Completed", false),
                  _buildFilterChip("Cancelled", false),
                ],
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
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.map, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2533),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 36,
        decoration: BoxDecoration(
          color: selected ? Colors.blue : const Color(0xFF1C2533),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade800,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final bool cancelled = order["cancelled"] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2533),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cancelled
                          ? Colors.red.shade900
                          : Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      cancelled ? Icons.close : Icons.inventory_2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order["id"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        order["date"],
                        style: TextStyle(
                          fontSize: 12,
                          color: cancelled ? Colors.white54 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order["statusColor"]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      cancelled ? Icons.cancel : Icons.check_circle,
                      color: order["statusColor"],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order["status"],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: order["statusColor"],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Route
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoutePoint("Pickup", order["pickup"]),
              const SizedBox(height: 4),
              _buildRoutePoint("Drop-off", order["dropoff"], dropOff: true),
            ],
          ),
          const SizedBox(height: 8),
          // Footer
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF151C2B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order["items"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: cancelled ? Colors.white54 : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  order["price"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: cancelled
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: cancelled ? Colors.white54 : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(
    String title,
    String address, {
    bool dropOff = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dropOff ? Colors.blue : Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF101622), width: 2),
              ),
              child: dropOff
                  ? const Icon(Icons.location_on, size: 10, color: Colors.blue)
                  : null,
            ),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              address,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
