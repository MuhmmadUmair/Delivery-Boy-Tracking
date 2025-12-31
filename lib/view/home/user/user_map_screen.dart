// ignore_for_file: public_member_api_docs
import 'package:firebase_google_apple_notif/view/auth/profile_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';

class UserMapScreen extends StatefulWidget {
  static const CameraPosition _kJoharTownLahore = CameraPosition(
    target: LatLng(31.4697, 74.2728),
    zoom: 14.4746,
  );

  const UserMapScreen({super.key});

  @override
  State<UserMapScreen> createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Get user's current location and move camera
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLocation = LatLng(position.latitude, position.longitude);

    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 16),
        ),
      );
    }
    setState(() {});
  }

  /// Open draggable bottom sheet
  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xff0C1C14),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'New Order Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 60),
                      Text(
                        'Price: \$100',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 25,
                        child: CircleAvatar(
                          radius: 23,
                          child: Image(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=738&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Leather Bags',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 5),
                      Text('x 4', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.track_changes_outlined, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Pickup-   Liberty Market, Gulberg',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'Delivery-   Packages Mall, DHA/Gulberg Link Road ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      fixedSize: Size(380, 50),
                    ),
                    child: Text(
                      'View Order Details',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff242f3e),
        title: const Text('Home Screen', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileTypeSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomSheet,
        // onPressed: _determinePosition,
        child: const Icon(Icons.my_location),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) async {
              _mapController = controller;
              final style = await rootBundle.loadString(
                'assets/json/night_theme.json',
              );
              _mapController!.setMapStyle(style);

              if (_currentLocation != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _currentLocation!, zoom: 16),
                  ),
                );
              }
            },
            initialCameraPosition: _currentLocation != null
                ? CameraPosition(target: _currentLocation!, zoom: 16)
                : UserMapScreen._kJoharTownLahore,
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _openBottomSheet,
              child: Icon(Icons.list),
            ),
          ),
        ],
      ),
    );
  }
}
