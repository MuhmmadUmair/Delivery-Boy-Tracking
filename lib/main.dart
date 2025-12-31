import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_google_apple_notif/app/styles/color_scheme.dart';
import 'package:firebase_google_apple_notif/app/styles/typography.dart';
import 'package:firebase_google_apple_notif/view/auth/profile_type.dart';
import 'package:firebase_google_apple_notif/view/home/manager/track_delivery_boy.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X reference (best default)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Delivery Boy Tracking',
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              AppColorScheme.light(),
              TypographyExtension.from(AppColorScheme.light()),
            ],
          ),
          home: const ProfileTypeSelectionScreen(),
        );
      },
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Message: ${message.notification?.title}');
}
