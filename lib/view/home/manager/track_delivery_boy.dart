import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

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
  GoogleMapController? _mapController;
  BitmapDescriptor? _markerIcon;
  String? _mapStyle;
  final DatabaseReference rtdbRef = FirebaseDatabase.instance.ref(
    'delivery_boys',
  );
  final String managerUid = "VHKCoMWZeGbb4MDaabLJYslxztp2";

  List<Map<String, dynamic>> _deliveryBoys = [];
  String _search = '';
  String _selectedStatus = 'All';
  final List<String> _filters = ['All', 'Moving', 'Idle', 'Offline'];

  @override
  void initState() {
    super.initState();
    _loadMarker();
    _loadMapStyle();
    _listenDeliveryBoys();
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
    setState(() {});
  }

  void _listenDeliveryBoys() {
    FirebaseFirestore.instance
        .collection('managers')
        .doc(managerUid)
        .snapshots()
        .listen((managerSnap) {
          final deliveryBoyIds = List<String>.from(
            managerSnap.data()?['deliveryBoys'] ?? [],
          );
          if (deliveryBoyIds.isEmpty) return setState(() => _deliveryBoys = []);

          rtdbRef.onValue.listen((rtdbSnap) {
            final rtdbData = rtdbSnap.snapshot.value != null
                ? Map<String, dynamic>.from(rtdbSnap.snapshot.value as Map)
                : {};

            FirebaseFirestore.instance
                .collection('delivery_boys')
                .where('uid', whereIn: deliveryBoyIds)
                .snapshots()
                .listen((boysSnap) {
                  final boys = boysSnap.docs.map((doc) {
                    final data = doc.data();
                    final uid = data['uid'];
                    final rtdbBoy = rtdbData[uid] as Map<dynamic, dynamic>?;

                    Map<String, double>? location;
                    if (rtdbBoy?['location'] != null) {
                      final loc = rtdbBoy!['location'] as Map;
                      location = {
                        'lat': loc['lat']?.toDouble() ?? 0,
                        'lng': loc['lng']?.toDouble() ?? 0,
                      };
                    }

                    return {
                      'uid': uid,
                      'name': data['name'] ?? 'Unknown',
                      'status':
                          rtdbBoy?['status']?.toString().toLowerCase() ??
                          'offline',
                      'lastStatusUpdate': rtdbBoy != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                              rtdbBoy['lastUpdated'] ?? 0,
                            )
                          : null,
                      'lastLocation': location,
                    };
                  }).toList();

                  setState(() => _deliveryBoys = boys);
                });
          });
        });
  }

  String _getRealTimeStatus(Map<String, dynamic> d) {
    final status = (d['status'] ?? 'offline').toString().toLowerCase();
    final lastUpdate = d['lastStatusUpdate'] as DateTime?;
    if (lastUpdate == null) return 'offline';
    return DateTime.now().difference(lastUpdate).inSeconds > 60
        ? 'offline'
        : status;
  }

  Set<Marker> _buildMarkers() {
    return _deliveryBoys
        // .where((d) {
        // final status = _getRealTimeStatus(d);
        // return (status == 'moving' || status == 'idle') &&
        //       d['lastLocation'] != null;
        // })
        .where((d) => d['lastLocation'] != null)
        .map((d) {
          final loc = d['lastLocation'];
          return Marker(
            markerId: MarkerId(d['uid']),
            position: LatLng(loc['lat'], loc['lng']),
            infoWindow: InfoWindow(title: d['name']),
            icon: _markerIcon ?? BitmapDescriptor.defaultMarker,
          );
        })
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: TrackDeliveryBoysScreen.initialPosition,
            markers: _buildMarkers(),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
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

  @override
  Widget build(BuildContext context) {
    final filtered = deliveryBoys.where((d) {
      final nameMatch = (d['name'] ?? '').toLowerCase().contains(
        search.toLowerCase(),
      );
      if (selectedStatus == 'All') return nameMatch;
      return nameMatch && _getStatus(d) == selectedStatus.toLowerCase();
    }).toList();

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
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://i.pravatar.cc/150',
                                ),
                                fit: BoxFit.cover,
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
                                color: status == 'moving'
                                    ? Colors.green
                                    : status == 'idle'
                                    ? Colors.orange
                                    : Colors.grey,
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
                          color: status == 'moving'
                              ? Colors.green
                              : status == 'idle'
                              ? Colors.orange
                              : Colors.grey,
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
