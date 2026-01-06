import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:firebase_google_apple_notif/services/manager_service.dart';
import 'package:flutter/material.dart';

class AddDeliveryBoyScreen extends StatefulWidget {
  const AddDeliveryBoyScreen({super.key});

  @override
  State<AddDeliveryBoyScreen> createState() => _AddDeliveryBoyScreenState();
}

class _AddDeliveryBoyScreenState extends State<AddDeliveryBoyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  final ManagerService _managerService = ManagerService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String getDeliveryCode() {
    return _controllers.map((c) => c.text.toUpperCase()).join();
  }

  Future<void> _linkDeliveryBoy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = getDeliveryCode();
    if (code.length != 5) {
      setState(() {
        _errorMessage = 'Please enter a valid 5-character code';
        _isLoading = false;
      });
      return;
    }

    try {
      await _managerService.linkDeliveryBoyByCode(code);

      if (mounted) {
        Navigator.pop(context);
        context.flushBarSuccessMessage(
          message: "Delivery boy linked successfully!",
        );
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = const Color(0xFF135BEC);
    final surfaceLight = Colors.white;
    final surfaceDark = const Color(0xFF1A2433);
    final backgroundDark = const Color(0xFF101622);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Add Delivery Boy',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 96,
                              width: 96,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(Icons.person_add, size: 48, color: primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Link New Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter the unique 5-character code displayed on the delivery boy's profile settings.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Code input fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: SizedBox(
                                width: 48,
                                height: 56,
                                child: TextField(
                                  focusNode: _focusNodes[index],
                                  controller: _controllers[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RobotoMono',
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: isDark
                                        ? surfaceDark
                                        : surfaceLight,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onChanged(value, index),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : _linkDeliveryBoy,
                            icon: const Icon(Icons.link),
                            label: Text(
                              _isLoading ? 'Linking...' : 'Link Delivery Boy',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
