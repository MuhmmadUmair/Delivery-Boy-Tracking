import 'package:firebase_google_apple_notif/app/components/my_button.dart';
import 'package:firebase_google_apple_notif/app/components/my_form_text_field.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/flush_bar_extension.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/validations_exception.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/widgets/language_menu.dart';
import 'package:firebase_google_apple_notif/view/auth/widgets/social_login_btn.dart';
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
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _confirmPasswordController.removeListener(_updateButtonState);

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    isFormFilled.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isFilled =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty;
    isFormFilled.value = isFilled;
  }

  void fillFormForTesting() {
    if (kDebugMode) {
      _nameController.text = 'Test Manager';
      _emailController.text = 'mtalha2410+manager@gmail.com';
      _passwordController.text = '12345678';
      _confirmPasswordController.text = '12345678';
      isFormFilled.value = true;
    }
  }

  Future<void> _signup() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService().createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        profileType: widget.profileType,
        phone: '',
        address: '',
      );

      if (!mounted) return;
      context.flushBarSuccessMessage(message: "Account created successfully");

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121721),
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
                    onSelected: (lang) =>
                        debugPrint('Selected Language: $lang'),
                  ),
                ],
              ),
              SizedBox(height: 36.h),
              Row(
                children: [
                  Text(
                    'Welcome to Manager',
                    style: context.typography.title.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.waving_hand, color: Colors.amber),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Please fill all the fields to create a new account.',
                style: context.typography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 42.h),

              // Name
              Text(
                'Name',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                hint: 'Enter your name',
                suffixIcon: Icon(Icons.person_2_outlined),
                controller: _nameController,
                readOnly: isLoading,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Name is required.';
                  if (!v.nameValidator()) return 'Invalid name';
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Email
              Text(
                'Email',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: Icon(Icons.mail_outline),
                controller: _emailController,
                readOnly: isLoading,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.emailValidator()) return 'Invalid email';
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Password
              Text(
                'Password',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                hint: 'Enter password',
                obscureText: hidePassword,
                controller: _passwordController,
                readOnly: isLoading,
                focusNode: _passwordFocusNode,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => hidePassword = !hidePassword),
                  child: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (!v.lessSecurePasswordValidator()) return 'Weak password';
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Confirm Password
              Text(
                'Confirm Password',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                hint: 'Enter password',
                obscureText: hideConfirmPassword,
                controller: _confirmPasswordController,
                readOnly: isLoading,
                focusNode: _confirmPasswordFocusNode,
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                    () => hideConfirmPassword = !hideConfirmPassword,
                  ),
                  child: Icon(
                    hideConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Confirm password is required';
                  if (v != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 36.h),

              // Signup Button
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

              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Container(color: Colors.white70, height: 1.5.h),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Sign Up With',
                    style: context.typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(color: Colors.white70, height: 1.5.h),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SocialLoginBtn(
                    type: 'apple',
                    onTap: () => debugPrint('Apple login'),
                  ),
                  SocialLoginBtn(
                    type: 'google',
                    onTap: () => debugPrint('Google login'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have account?',
                    style: context.typography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.w),
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
