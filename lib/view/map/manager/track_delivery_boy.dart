import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';

class TrackDeliveryBoysScreen extends StatefulWidget {
  const TrackDeliveryBoysScreen({super.key});

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(31.4644284, 74.2565352),
    zoom: 14,
  );

  @override
  State<TrackDeliveryBoysScreen> createState() =>
      _TrackDeliveryBoysScreenState();
}

class _TrackDeliveryBoysScreenState extends State<TrackDeliveryBoysScreen> {
  BitmapDescriptor? _markerIcon;
  String? _mapStyle;

  final DatabaseReference rtdbRef = FirebaseDatabase.instance.ref(
    'delivery_boys',
  );
  final ManagerService _managerService = ManagerService();

  List<Map<String, dynamic>> _deliveryBoys = [];
  String _search = '';
  String _selectedStatus = 'All';
  final List<String> _filters = ['All', 'Moving', 'Idle', 'Offline'];

  StreamSubscription<DatabaseEvent>? _rtdbSub;
  StreamSubscription<QuerySnapshot>? _boysSub;

  @override
  void initState() {
    super.initState();
    _loadMarker();
    _loadMapStyle();
    _listenDeliveryBoys();
  }

  @override
  void dispose() {
    _rtdbSub?.cancel();
    _boysSub?.cancel();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString(Assets.json.nightTheme);
  }

  Future<void> _loadMarker() async {
    final data = await rootBundle.load(Assets.images.bike.path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 64,
    );
    final frame = await codec.getNextFrame();
    final bytes = (await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    _markerIcon = BitmapDescriptor.fromBytes(bytes);
    if (mounted) setState(() {});
  }

  void _listenDeliveryBoys() {
    final currentManagerUid = FirebaseAuth.instance.currentUser!.uid;

    // Listen RTDB changes
    _rtdbSub = rtdbRef.onValue.listen((rtdbSnap) {
      final rtdbDataRaw = rtdbSnap.snapshot.value as Map<dynamic, dynamic>?;
      final rtdbData = rtdbDataRaw != null
          ? rtdbDataRaw.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};

      // Listen Firestore delivery boys for current manager
      _boysSub = FirebaseFirestore.instance
          .collection('delivery_boys')
          .where('managerId', isEqualTo: currentManagerUid)
          .snapshots()
          .listen((boysSnap) {
            final boys = boysSnap.docs.map((doc) => doc.data()).toList();
            final merged = _managerService.mergeDeliveryBoys(boys, rtdbData);

            if (mounted) setState(() => _deliveryBoys = merged);
          });
    });
  }

  Set<Marker> _buildMarkers() {
    final now = DateTime.now();
    return _deliveryBoys
        .where((d) => d['lastLocation'] != null)
        .where((d) {
          final lastUpdate = d['lastStatusUpdate'] as DateTime?;
          final status = d['status']?.toString().toLowerCase() ?? 'offline';
          if (lastUpdate == null) return false;
          if (now.difference(lastUpdate).inSeconds > 60) return false;
          if (status == 'offline') return false;
          return true;
        })
        .map((d) {
          final loc = d['lastLocation'];
          return Marker(
            markerId: MarkerId(d['uid']),
            position: LatLng(
              (loc['lat'] as num).toDouble(),
              (loc['lng'] as num).toDouble(),
            ),
            infoWindow: InfoWindow(title: d['name']),
            icon: _markerIcon ?? BitmapDescriptor.defaultMarker,
          );
        })
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: TrackDeliveryBoysScreen.initialPosition,
              markers: _buildMarkers(),
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                if (_mapStyle != null) controller.setMapStyle(_mapStyle);
              },
            ),
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _searchBar(),
                  const SizedBox(height: 10),
                  _filterChips(),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff192233),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _openBottomSheet,
                child: const Text(
                  'Fleet Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() => Container(
    height: 50,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xff192233),
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => setState(() => _search = v),
      decoration: const InputDecoration(
        hintText: 'Find rider',
        hintStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(Icons.search, color: Colors.white54),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _filterChips() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => ChoiceChip(
        label: Text(_filters[i]),
        selected: _filters[i] == _selectedStatus,
        selectedColor: Colors.blue,
        backgroundColor: const Color(0xff192233),
        labelStyle: const TextStyle(color: Colors.white),
        onSelected: (_) => setState(() => _selectedStatus = _filters[i]),
      ),
    ),
  );

  void _openBottomSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xff192233),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FleetBottomSheet(
      deliveryBoys: _deliveryBoys,
      search: _search,
      selectedStatus: _selectedStatus,
      filters: _filters,
    ),
  );
}

// ---------------------- Bottom Sheet ----------------------
class FleetBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> deliveryBoys;
  final String search;
  final String selectedStatus;
  final List<String> filters;

  const FleetBottomSheet({
    super.key,
    required this.deliveryBoys,
    required this.search,
    required this.selectedStatus,
    required this.filters,
  });

  String _getStatus(Map<String, dynamic> d) {
    final lastUpdate = d['lastStatusUpdate'] as DateTime?;
    if (lastUpdate == null) return 'offline';
    if (DateTime.now().difference(lastUpdate).inSeconds > 60) return 'offline';
    return (d['status'] ?? 'offline').toLowerCase();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'moving':
        return Colors.green;
      case 'idle':
        return Colors.amber;
      case 'offline':
      default:
        return Colors.grey;
    }
  }

  Widget _statCard(String title, String value) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xff101622).withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = deliveryBoys.where((d) {
      final nameMatch = (d['name'] ?? '').toLowerCase().contains(
        search.toLowerCase(),
      );
      if (selectedStatus == 'All') return nameMatch;
      return nameMatch && _getStatus(d) == selectedStatus.toLowerCase();
    }).toList();

    final activeCount = deliveryBoys
        .where((d) => _getStatus(d) == 'moving')
        .length;
    final idleCount = deliveryBoys.where((d) => _getStatus(d) == 'idle').length;
    final totalDistance = deliveryBoys.fold<double>(
      0,
      (sum, d) => sum + (d['distance']?.toDouble() ?? 0),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Fleet Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statCard('Active Riders', activeCount.toString()),
                const SizedBox(width: 8),
                _statCard('Idle', idleCount.toString()),
                const SizedBox(width: 8),
                _statCard('Distance', '${totalDistance.toStringAsFixed(1)} km'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final d = filtered[i];
                  final status = _getStatus(d);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  d['imageUrl'] ?? 'https://i.pravatar.cc/150',
                                ),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: _statusColor(status).withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 14,
                              width: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _statusColor(status),
                                border: Border.all(
                                  color: const Color(0xff192233),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d['name'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
