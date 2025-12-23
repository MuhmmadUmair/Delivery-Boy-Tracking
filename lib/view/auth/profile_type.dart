import 'package:firebase_google_apple_notif/app/core/enums/user_type.dart';
import 'package:firebase_google_apple_notif/app/styles/app_radiuses.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';
import 'package:firebase_google_apple_notif/view/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTypeSelectionScreen extends StatelessWidget {
  const ProfileTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Select your profile type according to your need.',
              style: TextStyle(fontSize: 14.sp),
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
                topMargin: 0,
                bottomMargin: 100,
                backgroundColor: context.colors.buttonPrimary,
                userType: UserType.manager,
              ),
              const Spacer(),
              AccountTypeCard(
                topMargin: 100,
                bottomMargin: 0,
                backgroundColor: context.colors.buttonDisabled,
                userType: UserType.delivery,
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
    required this.topMargin,
    required this.bottomMargin,
    required this.backgroundColor,
    required this.userType,
  });

  final double topMargin;
  final double bottomMargin;
  final Color backgroundColor;
  final UserType userType;

  bool get isManager => userType == UserType.manager;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //   Navigate to Login & pass userType
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Login(profileType: userType), // Pass enum
          ),
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
              ),
            ),
            Text(
              isManager ? 'Manager' : 'Delivery Boy',
              style: context.typography.title.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
