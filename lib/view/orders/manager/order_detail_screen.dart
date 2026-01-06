import 'package:firebase_google_apple_notif/view/orders/manager/assign_task.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  // ======= Sample Data =======
  final Map<String, dynamic> riderInfo = const {
    'name': 'Michael B.',
    'status': 'Online',
    'battery': 85,
    'image':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBv1UyxsuOyaXVNCVHaY4640nd5-uHNACwxKYGKN1C0ClQczP7tZGly4MkWI8vmYb43cFTQy-mAGIKs1psz9Lwzs-oXU3VWbXPGorXRmDTRkHVNX5osw70XgXoZhLwICAEGFacmcZD1N5e48We1aRRfXRkEMFhzrNBRPV-MaDLIVntbfZtweVeM-NEStkJU6r7forIAr6JFsrNUh7EuXRESEgAJgc6y1fDAIYv7qif5P3jJF_2A8rg_opZmDIx_hDSv_Vo72U-rxKo',
    'vehicleIcon': Icons.directions_bike,
    'totalDistance': 42.5,
    'completedOrders': 8,
    'totalOrders': 12,
  };

  final Map<String, dynamic> currentTask = const {
    'orderId': '2045',
    'customer': 'Alice Morgan',
    'amount': 34.50,
    'paymentMethod': 'Cash on Delivery',
    'pickup': {
      'place': 'Burger King, Downtown',
      'address': '124 Main St, Suite 4',
      'time': '10:45 AM',
      'status': 'Picked Up',
      'statusColor': Colors.orange,
    },
    'dropoff': {
      'place': 'Home',
      'address': '45 Park Avenue, Apt 12B',
      'time': '11:10 AM',
      'status': 'Drop-off',
      'statusColor': Colors.red,
    },
    'items': [
      {'name': '2x Whopper Meal (Large)', 'price': 24.0},
      {'name': '1x Onion Rings', 'price': 5.5},
      {'name': '1x Vanilla Shake', 'price': 5.0},
    ],
    'status': 'In Transit',
    'eta': '2 mins away',
  };

  final List<Map<String, dynamic>> nextQueue = const [
    {
      'orderId': '2046',
      'place': 'Starbucks, West Mall',
      'drop': 'Office 402, Tech Park',
      'status': 'Pending',
      'statusColor': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> completedOrders = const [
    {'orderId': '2040', 'deliveredAt': '09:45 AM', 'amount': 12.0},
    {'orderId': '2038', 'deliveredAt': '08:30 AM', 'amount': 28.45},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[700],
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          riderInfo['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${riderInfo['status']} • Battery ${riderInfo['battery']}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF232F48),
                      child: IconButton(
                        icon: const Icon(Icons.call, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rider Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2230),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Distance',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Completed',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${riderInfo['totalDistance']} km',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${riderInfo['completedOrders']}/${riderInfo['totalOrders']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            riderInfo['completedOrders'] /
                            riderInfo['totalOrders'],
                        color: const Color(0xFF135BEC),
                        backgroundColor: const Color(0xFF232F48),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Current Task
                Text(
                  'Current Task',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                CurrentTaskCard(task: currentTask),

                const SizedBox(height: 16),

                // Next in Queue
                Text(
                  'Next in Queue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: nextQueue
                      .map((order) => NextQueueCard(order: order))
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Completed Orders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed Today',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232F48),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${completedOrders.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: completedOrders
                      .map((order) => CompletedOrderCard(order: order))
                      .toList(),
                ),
                const SizedBox(height: 80), // space for button
              ],
            ),

            // Assign New Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AssignTaskScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF135BEC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.add_task, color: Colors.white),
                label: const Text(
                  'Assign New',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Current Task Card =======
class CurrentTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  const CurrentTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${task['orderId']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Customer: ${task['customer']}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${task['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      task['paymentMethod'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pickup
            Text(
              '${task['pickup']['status']} • ${task['pickup']['time']}',
              style: TextStyle(
                fontSize: 10,
                color: task['pickup']['statusColor'],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              task['pickup']['place'],
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              task['pickup']['address'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            // Dropoff
            Text(
              '${task['dropoff']['status']} • Est. ${task['dropoff']['time']}',
              style: TextStyle(
                fontSize: 10,
                color: task['dropoff']['statusColor'],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              task['dropoff']['place'],
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              task['dropoff']['address'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            // Items
            Text(
              'Items (${task['items'].length})',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              children: task['items']
                  .map<Widget>(
                    (item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '\$${item['price']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: const Icon(Icons.check_circle, color: Colors.white),
              ),
              label: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: const Text(
                  'Mark as Completed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF135BEC),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Next Queue Card =======
class NextQueueCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const NextQueueCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF232F48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order['orderId']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(color: order['statusColor'], fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(order['place'], style: const TextStyle(color: Colors.white70)),
          Text(
            order['drop'],
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ======= Completed Order Card =======
class CompletedOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const CompletedOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF232F48)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order['orderId']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Delivered at ${order['deliveredAt']}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '\$${order['amount']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
