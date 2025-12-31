import 'package:flutter/material.dart';
import 'package:firebase_google_apple_notif/app/components/my_button.dart';
import 'package:firebase_google_apple_notif/app/components/my_form_text_field.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:firebase_google_apple_notif/app/utils/extensions/validations_exception.dart';
import 'package:firebase_google_apple_notif/services/common/auth_service.dart';
import 'package:firebase_google_apple_notif/view/auth/widgets/language_menu.dart';
import 'package:firebase_google_apple_notif/view/auth/widgets/social_login_btn.dart';
import 'package:firebase_google_apple_notif/view/home/manager/manager_dashbord.dart';
import 'package:firebase_google_apple_notif/view/home/user/user_home_screen.dart';
import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.profileType});
  final UserType profileType;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;

  bool get _isFormFilled =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fillFormForTesting();
    emailController.addListener(_onTextChange);
    passwordController.addListener(_onTextChange);
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  void _fillFormForTesting() {
    if (kDebugMode) {
      emailController.text = widget.profileType == UserType.manager
          ? 'manager@example.com'
          : 'delivery@example.com';
      passwordController.text = '12345678';
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        profileType: widget.profileType,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.profileType == UserType.manager
              ? const ManagerDashboardScreen()
              : const DeliveryDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      await _authService.signInWithGoogle(profileType: widget.profileType);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.profileType == UserType.manager
              ? const ManagerDashboardScreen()
              : const DeliveryDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121721),
      appBar: AppBar(backgroundColor: Color(0xff121721)),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Text(
                    widget.profileType == UserType.manager
                        ? 'Manager Login'
                        : 'Delivery Login',
                    style: context.typography.title.copyWith(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  LanguageMenu(
                    selectedLanguage: Language('en', 'Eng'),
                    onSelected: (lang) {
                      debugPrint('Selected Language: $lang');
                    },
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Text(
                    'Welcome back',
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
                'We are happy to see you again. To use your account, you should log in first.',
                style: context.typography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Email',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                suffixIcon: Icon(Icons.mail_outline),
                hint: 'Enter your email',
                controller: emailController,
                textCapitalization: TextCapitalization.none,
                readOnly: isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email is required';
                  if (!value.emailValidator()) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              Text(
                'Password',
                style: context.typography.title.copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6.h),
              MyFormTextField(
                obscureText: hidePassword,
                controller: passwordController,
                hint: 'Enter your password',
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => hidePassword = !hidePassword),
                  child: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                textCapitalization: TextCapitalization.none,
                readOnly: isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Password is required';
                  if (!value.lessSecurePasswordValidator()) {
                    return 'Password must contain at least one uppercase letter, one number, and one special character.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Forgot password UI only
                    },
                    child: Text(
                      'Forgot password?',
                      style: context.typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: context.colors.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              MyButton(
                label: 'Log In',
                isLoading: isLoading,
                onPressed: _isFormFilled && !isLoading ? _handleLogin : null,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white70, thickness: 1.5.h),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Log In With',
                    style: context.typography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Divider(color: Colors.white70, thickness: 1.5.h),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SocialLoginBtn(type: 'apple', onTap: () async {}),
                  SocialLoginBtn(type: 'google', onTap: _handleGoogleLogin),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: context.typography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      AuthService.gotoSignup(context, widget.profileType);
                    },
                    child: Text(
                      'Sign Up',
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
