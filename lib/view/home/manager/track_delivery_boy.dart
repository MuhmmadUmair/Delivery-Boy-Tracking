// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase logic commented

class TrackDeliveryBoysScreen extends StatefulWidget {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.4644284, 74.2565352),
    zoom: 14.0,
  );

  const TrackDeliveryBoysScreen({super.key});

  @override
  State<TrackDeliveryBoysScreen> createState() =>
      _TrackDeliveryBoysScreenState();
}

class _TrackDeliveryBoysScreenState extends State<TrackDeliveryBoysScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _deliveryBoyIcon;
  String? _mapStyle;
  final Map<String, Marker> _markers = {};
  final Random _random = Random();

  // Dummy delivery boys data
  final List<Map<String, dynamic>> _dummyDeliveryBoys = List.generate(10, (i) {
    return {
      'id': 'db_$i',
      'name': 'Delivery Boy ${i + 1}',
      'location': {
        'lat': 31.4644284 + 0.01 * (i % 3),
        'lng': 74.2565352 + 0.01 * (i % 4),
      },
    };
  });

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadDeliveryBoyIcon();
    _startDummyMovement();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeliveryBoyIcon() async {
    _deliveryBoyIcon = await _resizeMarker(Assets.images.bike.path, 64);
    setState(() {});
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString(Assets.json.nightTheme);
  }

  Future<BitmapDescriptor> _resizeMarker(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final bytes = (await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(bytes);
  }

  // Simulate live movement
  void _startDummyMovement() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        for (var boy in _dummyDeliveryBoys) {
          final loc = boy['location'];
          loc['lat'] += (_random.nextDouble() - 0.5) * 0.001;
          loc['lng'] += (_random.nextDouble() - 0.5) * 0.001;

          _markers[boy['id']] = Marker(
            markerId: MarkerId(boy['id']),
            position: LatLng(loc['lat'], loc['lng']),
            infoWindow: InfoWindow(title: boy['name']),
            icon:
                _deliveryBoyIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          );
        }
      });
    });
  }

  // Firestore stream (commented for now)
  /*
  Stream<QuerySnapshot> get _deliveryBoysStream => FirebaseFirestore.instance
      .collection('users')
      .where('profileType', isEqualTo: 'delivery')
      .snapshots();

  void _updateMarkersFromFirestore(QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'];
      if (location == null || location['lat'] == null || location['lng'] == null) continue;

      final markerId = doc.id;
      _markers[markerId] = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(location['lat'], location['lng']),
        infoWindow: InfoWindow(title: data['name'] ?? 'Delivery Boy'),
        icon: _deliveryBoyIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery Boys'),
        backgroundColor: const Color(0xff242f3e),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.my_location),
      ),
      body: GoogleMap(
        initialCameraPosition: TrackDeliveryBoysScreen._initialPosition,
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (controller) {
          _mapController = controller;
          if (_mapStyle != null) _mapController!.setMapStyle(_mapStyle);
        },

        // Uncomment below to use Firestore instead of dummy data
        // onMapCreated: (controller) {
        //   _mapController = controller;
        //   if (_mapStyle != null) _mapController!.setMapStyle(_mapStyle);
        //   _deliveryBoysStream.listen((snapshot) {
        //     setState(() {
        //       _updateMarkersFromFirestore(snapshot);
        //     });
        //   });
        // },
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: false,
      ),
    );
  }
}
