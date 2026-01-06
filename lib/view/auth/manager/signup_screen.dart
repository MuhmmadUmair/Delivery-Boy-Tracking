import 'package:firebase_google_apple_notif/app/components/my_button.dart';
import 'package:firebase_google_apple_notif/app/components/my_form_text_field.dart';
import 'package:firebase_google_apple_notif/app/data/exception/app_exceptions.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/validations_exception.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/widgets/language_menu.dart';
import 'package:firebase_google_apple_notif/view/home/manager/manager_dashbord.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';

class ManagerSignupScreen extends StatefulWidget {
  final UserType profileType;

  const ManagerSignupScreen({super.key, this.profileType = UserType.manager});

  @override
  State<ManagerSignupScreen> createState() => _ManagerSignupScreenState();
}

class _ManagerSignupScreenState extends State<ManagerSignupScreen> {
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isFormFilled = ValueNotifier(false);
  bool isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fillFormForTesting();

    _nameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _addressController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    isFormFilled.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    isFormFilled.value =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty;
  }

  void fillFormForTesting() {
    if (kDebugMode) {
      _nameController.text = 'Test Manager';
      _emailController.text = 'manager@example.com';
      _phoneController.text = '03001234567';
      _addressController.text = 'Lahore, Pakistan';
      _passwordController.text = '12345678';
      _confirmPasswordController.text = '12345678';
      isFormFilled.value = true;
    }
  }

  Future<void> _signup() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await AuthService().createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        profileType: widget.profileType,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final user = response.data; // ApiResponse<User> -> User
      debugPrint('$user');

      if (!mounted) return;
      context.flushBarSuccessMessage(message: "Account created successfully");

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()),
      );
    } on AppException catch (e) {
      if (mounted) context.flushBarErrorMessage(message: e.debugMessage);
    } catch (e) {
      if (mounted) context.flushBarErrorMessage(message: e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    FocusNode? focusNode,
    VoidCallback? toggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.title.copyWith(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        MyFormTextField(
          hint: 'Enter $label',
          controller: controller,
          obscureText: obscure,
          focusNode: focusNode,
          keyboardType: keyboardType,
          readOnly: isLoading,
          suffixIcon: toggle != null
              ? GestureDetector(
                  onTap: toggle,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121721),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Text(
                    'Manager',
                    style: context.typography.title.copyWith(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  LanguageMenu(
                    selectedLanguage: Language('en', 'Eng'),
                    onSelected: (lang) => debugPrint('$lang'),
                  ),
                ],
              ),
              SizedBox(height: 36.h),

              _buildTextField(
                label: 'Name',
                controller: _nameController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Name is required';
                  if (!v.nameValidator()) return 'Invalid name';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.emailValidator()) return 'Invalid email';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone number is required';
                  if (!v.phoneNumberValidator()) return 'Invalid phone number';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                label: 'Address',
                controller: _addressController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Address is required';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscure: hidePassword,
                toggle: () => setState(() => hidePassword = !hidePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (!v.lessSecurePasswordValidator()) return 'Weak password';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscure: hideConfirmPassword,
                toggle: () =>
                    setState(() => hideConfirmPassword = !hideConfirmPassword),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Confirm password is required';
                  if (v != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 36.h),

              ValueListenableBuilder<bool>(
                valueListenable: isFormFilled,
                builder: (_, isFilled, __) {
                  return MyButton(
                    label: 'Sign Up',
                    isLoading: isLoading,
                    onPressed: isFilled && !isLoading ? _signup : null,
                  );
                },
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have account?',
                    style: context.typography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Sign In',
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.buttonPrimary,
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
}
