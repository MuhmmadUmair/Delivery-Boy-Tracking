import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/components/address_autocomplete.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  // ===================== VARIABLES =====================
  String? selectedDriverId;
  String? selectedDriverName;
  LatLng pickupLatLng = const LatLng(31.5, 74.35); // Default Firdous Market
  LatLng? dropLatLng;
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pickupController = TextEditingController(text: "Firdous Market");
  final _destinationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _managerService = ManagerService();
  final _rtdbRef = FirebaseDatabase.instance.ref('delivery_boys');

  StreamSubscription<DatabaseEvent>? _rtdbSub;
  StreamSubscription<QuerySnapshot>? _boysSub;

  List<Map<String, dynamic>> _deliveryBoys = [];

  // ===================== COLORS =====================
  static const _primaryColor = Color(0xFF135BEC);
  static const _backgroundDark = Color(0xFF101622);
  static const _surfaceDark = Color(0xFF192233);
  static const _borderDark = Color(0xFF324457);
  static const _textSecondary = Color(0xFF92A4C9);

  @override
  void initState() {
    super.initState();
    _listenDeliveryBoys();

    // Listen to text changes to update button state
    _nameController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _pickupController.addListener(_updateButtonState);
    _destinationController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _rtdbSub?.cancel();
    _boysSub?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateButtonState() => setState(() {});

  bool get _isButtonEnabled {
    return selectedDriverId != null &&
        _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _pickupController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty &&
        dropLatLng != null &&
        !isLoading;
  }

  // ===================== LISTEN DELIVERY BOYS =====================
  void _listenDeliveryBoys() {
    final managerId = FirebaseAuth.instance.currentUser!.uid;

    _rtdbSub = _rtdbRef.onValue.listen((rtdbSnap) {
      final rtdbData =
          (rtdbSnap.snapshot.value as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          {};

      _boysSub = FirebaseFirestore.instance
          .collection('delivery_boys')
          .where('managerId', isEqualTo: managerId)
          .snapshots()
          .listen((snap) {
            final boys = snap.docs
                .map((e) => {...e.data(), 'uid': e.id})
                .toList();

            final merged = _managerService
                .mergeDeliveryBoys(boys, rtdbData)
                .where((b) {
                  final status = b['status']?.toString().toLowerCase();
                  return status != 'offline';
                })
                .map((b) {
                  if (b['status']?.toLowerCase() == 'idle')
                    b['status'] = 'Available';
                  return b;
                })
                .toList();

            if (mounted) setState(() => _deliveryBoys = merged);
          });
    });
  }

  // ===================== ASSIGN ORDER =====================
  Future<void> _assignOrder() async {
    if (!_isButtonEnabled) return;

    setState(() => isLoading = true);

    try {
      final orderId = await _managerService.assignOrder(
        deliveryBoyId: selectedDriverId!,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        pickupLocation: {
          'lat': pickupLatLng.latitude,
          'lng': pickupLatLng.longitude,
        },
        dropLocation: {
          'lat': dropLatLng!.latitude,
          'lng': dropLatLng!.longitude,
        },
        description: _descriptionController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      context.flushBarSuccessMessage(
        message: 'Order assigned successfully! Order ID: $orderId',
      );

      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _destinationController.clear();
      _descriptionController.clear();
      selectedDriverId = null;
      selectedDriverName = null;
      pickupLatLng = const LatLng(31.5, 74.35);
      dropLatLng = null;
      _pickupController.text = "Firdous Market";

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      final message = e is AppException
          ? e.userMessage
          : 'Unknown error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sectionTitle("Recipient Info"),
                    _inputField(_nameController, Icons.person, "e.g. Jane Doe"),
                    _inputField(
                      _phoneController,
                      Icons.call,
                      "e.g. +92 300 0000000",
                      keyboardType: TextInputType.phone,
                    ),
                    _sectionTitle("Pickup"),
                    AddressAutocompleteTextField(
                      controller: _pickupController,
                      apiKey: dotenv.env['PLACES_API_KEY']!,
                      hint: "Enter pickup location",
                      readOnly: isLoading,
                      onAddressSelected: (r) {
                        _pickupController.text = r.address;
                        pickupLatLng = LatLng(r.latitude, r.longitude);
                        _updateButtonState();
                      },
                    ),
                    _sectionTitle("Destination"),
                    AddressAutocompleteTextField(
                      controller: _destinationController,
                      apiKey: dotenv.env['PLACES_API_KEY']!,
                      hint: "Enter destination",
                      readOnly: isLoading,
                      onAddressSelected: (r) {
                        _destinationController.text = r.address;
                        dropLatLng = LatLng(r.latitude, r.longitude);
                        _updateButtonState();
                      },
                    ),
                    _descriptionField(),
                    _sectionTitle("Assign Delivery Boy"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: _deliveryBoys.map(_driverOption).toList(),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isButtonEnabled ? _assignOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              disabledBackgroundColor: _primaryColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Confirm Assignment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ===================== APP BAR =====================
  Widget _appBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _borderDark.withOpacity(0.5))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: _textSecondary)),
        ),
        const Text(
          "New Assignment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 45),
      ],
    ),
  );

  // ===================== INPUT FIELD =====================
  Widget _inputField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        filled: true,
        fillColor: _surfaceDark,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderDark),
        ),
      ),
    ),
  );

  Widget _descriptionField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: TextField(
      controller: _descriptionController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Order Description",
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        suffixIcon: const Icon(Icons.description, color: Colors.grey),
      ),
    ),
  );

  // ===================== SECTION TITLE =====================
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  // ===================== DRIVER CARD =====================
  Widget _driverOption(Map<String, dynamic> driver) {
    final name = driver['name'] ?? "Unknown";
    final uid = driver['uid'];
    final image =
        driver['image'] ??
        "https://ui-avatars.com/api/?name=Driver&background=135BEC&color=fff";
    final status = driver['status'] ?? "Available";
    final statusColor = (status.toLowerCase() == 'busy')
        ? Colors.orange
        : const Color(0xFF4ADE80);
    final distance = driver['distance'] ?? "0 km";
    final rating = driver['rating'] ?? 4.5;
    final isSelected = selectedDriverId == uid;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDriverId = uid;
          selectedDriverName = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : _surfaceDark,
          border: Border.all(
            color: isSelected ? _primaryColor : _borderDark,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(image)),
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.near_me, size: 14, color: Colors.grey),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: _primaryColor),
          ],
        ),
      ),
    );
  }
}
