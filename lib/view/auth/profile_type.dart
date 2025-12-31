import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/styles/app_radiuses.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';
import 'package:firebase_google_apple_notif/view/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTypeSelectionScreen extends StatelessWidget {
  const ProfileTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1B1F2B),
      appBar: AppBar(
        backgroundColor: const Color(0xff1B1F2B),
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6.h),
            Text(
              'Profile Type',
              style: context.typography.title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select your profile type according to your need.',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Row(
            children: [
              AccountTypeCard(
                userType: UserType.manager,
                backgroundColor: context.colors.buttonPrimary,
                topMargin: 0,
                bottomMargin: 100,
              ),
              const Spacer(),
              AccountTypeCard(
                userType: UserType.delivery,
                backgroundColor: const Color(0xff323C4D),
                topMargin: 100,
                bottomMargin: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountTypeCard extends StatelessWidget {
  const AccountTypeCard({
    super.key,
    required this.userType,
    required this.backgroundColor,
    required this.topMargin,
    required this.bottomMargin,
  });

  final UserType userType;
  final Color backgroundColor;
  final double topMargin;
  final double bottomMargin;

  bool get isManager => userType == UserType.manager;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen(profileType: userType)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
        width: 160.w,
        height: 381.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
          image: DecorationImage(
            image: AssetImage(Assets.images.blocksPattern.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              isManager ? 'assets/icons/shop.svg' : 'assets/icons/profile.svg',
              width: 48.w,
            ),
            SizedBox(height: 24.h),
            Text(
              'I am',
              style: context.typography.body.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Text(
              isManager ? 'Manager' : 'Delivery Boy',
              style: context.typography.title.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
