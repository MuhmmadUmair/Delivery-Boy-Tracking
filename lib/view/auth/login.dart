import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/data/response/api_response.dart';
import 'package:firebase_google_apple_notif/app/data/response/status.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';

import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/signin.dart';
import 'package:firebase_google_apple_notif/view/home/manager/admin_home_screen.dart';
import 'package:firebase_google_apple_notif/view/home/user/user_home_screen.dart';

class Login extends StatefulWidget {
  final UserType profileType;

  const Login({super.key, required this.profileType});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool obscureText = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* ---------------------------------------------------- */
  /* NAVIGATION */
  /* ---------------------------------------------------- */

  void _navigateToHome(UserType type) {
    if (!mounted) return;

    final screen = type == UserType.delivery
        ? const UserHomeScreen()
        : const AdminHomeScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /* ---------------------------------------------------- */
  /* FLUSHBAR HELPERS */
  /* ---------------------------------------------------- */

  void _showError(String message) {
    if (!mounted) return;
    context.flushBarErrorMessage(message: message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    context.flushBarSuccessMessage(message: message);
  }

  /* ---------------------------------------------------- */
  /* EMAIL LOGIN */
  /* ---------------------------------------------------- */

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    final ApiResponse<User> response = await _authService.signInWithEmail(
      email: email,
      password: password,
      profileType: widget.profileType,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.status == Status.completed) {
      _showSuccess('Login successful');

      // Allow Flushbar to be visible
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      _navigateToHome(widget.profileType);
    } else {
      _showError(response.message ?? 'Login failed');
    }
  }

  /* ---------------------------------------------------- */
  /* GOOGLE LOGIN */
  /* ---------------------------------------------------- */

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);

    final ApiResponse<User> response = await _authService.signInWithGoogle(
      profileType: widget.profileType,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.status == Status.completed) {
      _showSuccess('Login successful');

      // Allow Flushbar to be visible
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      _navigateToHome(widget.profileType);
    } else {
      _showError(response.message ?? 'Google login failed');
    }
  }

  /* ---------------------------------------------------- */
  /* UI */
  /* ---------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 140, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Login as ${widget.profileType.name}',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),

              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 20),

              _buildTextField(
                _passwordController,
                'Password',
                isObscure: obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => obscureText = !obscureText),
                ),
              ),

              const SizedBox(height: 40),

              // EMAIL LOGIN BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : _handleEmailLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              ),

              const SizedBox(height: 30),

              // GOOGLE LOGIN BUTTON
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleGoogleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 36),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black12,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Signin(profileType: widget.profileType),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------------------------------------------- */
  /* TEXT FIELD */
  /* ---------------------------------------------------- */

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
