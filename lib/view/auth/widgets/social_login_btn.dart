import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_google_apple_notif/gen/assets.gen.dart';
import 'package:firebase_google_apple_notif/app/styles/app_radiuses.dart';
import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';

class SocialLoginBtn extends StatelessWidget {
  const SocialLoginBtn({super.key, required this.type, required this.onTap});
  final String type; // 'apple' or 'google'
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 36.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadiuses.mediumRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              type == 'apple'
                  ? Assets.icons.appleLogo
                  : Assets.icons.googleIcon,
              height: 24.h,
            ),
            SizedBox(width: 8.w),
            Text(
              type == 'apple' ? 'Apple' : 'Google',
              style: context.typography.body.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
