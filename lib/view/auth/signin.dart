import 'package:firebase_google_apple_notif/app/data/response/status.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/validations_exception.dart';
import 'package:firebase_google_apple_notif/app/utils/service_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/login.dart';
import 'package:firebase_google_apple_notif/view/home/manager/admin_home_screen.dart';
import 'package:firebase_google_apple_notif/view/home/user/user_home_screen.dart';

class Signin extends StatefulWidget {
  final UserType profileType;

  const Signin({super.key, required this.profileType});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.profileType == UserType.delivery
            ? const UserHomeScreen()
            : const AdminHomeScreen(),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await _authService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        profileType: widget.profileType,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (!mounted) return;

      if (response.status == Status.completed) {
        context.flushBarSuccessMessage(message: 'Account created successfully');
        _navigateToHome();
      } else {
        context.flushBarErrorMessage(message: response.message.toString());
      }
    } catch (e) {
      ErrorHandler.handle(context, e, serviceName: 'Signup');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 20),

                /// Profile Image UI (logic skipped)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple.shade200,
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                _field(
                  controller: _nameController,
                  hint: 'Full Name',
                  validator: (v) =>
                      v!.nameValidator() ? null : 'Enter valid name',
                ),
                _gap(),
                _field(
                  controller: _emailController,
                  hint: 'Email',
                  validator: (v) =>
                      v!.emailValidator() ? null : 'Invalid email',
                ),
                _gap(),
                _field(
                  controller: _phoneController,
                  hint: 'Phone Number',
                  validator: (v) =>
                      v!.phoneNumberValidator() ? null : 'Invalid phone number',
                ),
                _gap(),
                _field(
                  controller: _addressController,
                  hint: 'Address',
                  validator: (v) =>
                      v!.addressValidator() ? null : 'Invalid address',
                ),
                _gap(),
                _field(
                  controller: _passwordController,
                  hint: 'Password',
                  obscure: obscurePassword,
                  validator: (v) =>
                      v!.passwordValidator() ? null : 'Weak password',
                  toggle: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                _gap(),
                _field(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  obscure: obscureConfirmPassword,
                  validator: (v) => v == _passwordController.text
                      ? null
                      : 'Passwords do not match',
                  toggle: () => setState(
                    () => obscureConfirmPassword = !obscureConfirmPassword,
                  ),
                ),
                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Login(profileType: widget.profileType),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 15);

  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }
}
