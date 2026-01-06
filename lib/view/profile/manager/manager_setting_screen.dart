import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:flutter/material.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

  @override
  State<ManagerSettingsScreen> createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  // Toggle states
  bool liveRefresh = true;
  bool movementAlerts = false;
  bool longStopAlerts = true;
  bool shiftEndReports = true;

  // Example data lists for future API integration
  final account = {
    "name": "James Anderson",
    "role": "Regional Logistics Manager",
    "imageUrl":
        "https://lh3.googleusercontent.com/aida-public/AB6AXuDiM3eeYiDRBR7UPnWt9miUqJuPgHfSFKTpPDEdJo3x-8j9VFGy6I70yBSr2-nTZ02ZKSqAXFib-vdLhCYberpKcCZqJTyZPWNUk5NsnlvUMD07PKY32_wljzB6FpjhVuDXp8esF2A-tBC6I7WrEWsd7hUYbCJSHOrD_JjhoNeD6uI-C-lLPEzAyrIaSdtrJCf-6Jn8V5lSWqHrY7TpAvGBdX_c2kL5MUT8vP9RdKI6-SFwSzHEV2YAYfhuWC7RXr6pwi0bHEknf1g",
  };

  final deliveryBoysOptions = [
    {"title": "Manage Team List", "icon": Icons.group},
    {"title": "Add New Delivery Boy", "icon": Icons.person_add},
  ];

  final trackingParameters = [
    {
      "title": "Stop Detection",
      "subtitle": "Alert after inactivity",
      "value": "5 mins",
    },
    {
      "title": "GPS Sensitivity",
      "subtitle": "Battery usage impact",
      "value": "High",
    },
  ];

  final notificationsOptions = [
    {"title": "Movement Alerts", "value": false},
    {"title": "Long Stop Alerts", "value": true},
    {"title": "Shift End Reports", "value": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // ===== Header =====
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF101622).withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade800),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Manager Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== Account Section =====
              _buildSectionTitle('Account'),
              _buildAccountCard(),

              const SizedBox(height: 16),

              // ===== Delivery Boys Management =====
              _buildSectionTitle('Delivery Boys Management'),
              _buildDeliveryBoysCard(),

              const SizedBox(height: 16),

              // ===== Tracking Parameters =====
              _buildSectionTitle('Tracking Parameters'),
              _buildTrackingCard(),

              const SizedBox(height: 16),

              // ===== Notifications =====
              _buildSectionTitle('Notifications'),
              _buildNotificationsCard(),

              const SizedBox(height: 16),

              // ===== Logout =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2433),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'App Version 2.4.0 (Build 512)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(account['imageUrl']!),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
              ),
            ],
          ),
          title: Text(
            account['name']!,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            account['role']!,
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF135BEC),
              elevation: 0,
            ),
            child: const Text('Edit'),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryBoysCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Active Staff
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Active Staff',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Currently on duty',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '12 Online',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // List options
            ...deliveryBoysOptions.map((item) {
              return ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF135BEC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 36,
                  height: 36,
                  child: Icon(item['icon'] as IconData, color: Colors.white),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: () {},
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children:
              trackingParameters.map((param) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade800),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            param['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            param['subtitle']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        param['value']!,
                        style: const TextStyle(
                          color: Color(0xFF135BEC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()..add(
                // Live Map Auto-refresh Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Map Auto-refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: liveRefresh,
                        onChanged: (val) => setState(() => liveRefresh = val),
                        activeColor: const Color(0xFF135BEC),
                        inactiveThumbColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2433),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildNotificationTile(
              'Movement Alerts',
              movementAlerts,
              (val) => setState(() => movementAlerts = val),
            ),
            _buildNotificationTile(
              'Long Stop Alerts',
              longStopAlerts,
              (val) => setState(() => longStopAlerts = val),
            ),
            _buildNotificationTile(
              'Shift End Reports',
              shiftEndReports,
              (val) => setState(() => shiftEndReports = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF135BEC),
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
