import 'package:firebase_google_apple_notif/app/components/global_unfocus_keyboard.dart';
import 'package:firebase_google_apple_notif/app/styles/app_radiuses.dart';
import 'package:flutter/material.dart';

class MyBottomSheet extends StatelessWidget {
  const MyBottomSheet({required this.child, super.key});

  final Widget child;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = false,
    bool enableDrag = false,
    bool useSafeArea = true,
    bool showDragHandle = false,
    bool isScrollControlled = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      backgroundColor: backgroundColor,
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      builder: (_) => GlobalUnfocusKeyboard(child: MyBottomSheet(child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadiuses.extraLargeRadius),
          topRight: Radius.circular(AppRadiuses.extraLargeRadius),
        ),
        // image: DecorationImage(
        //   image: AssetImage(Assets.images.bg.path),
        //   fit: BoxFit.cover,
        //   colorFilter: ColorFilter.mode(
        //     context.colors.background.withValues(alpha: 0.88),
        //     BlendMode.srcOver,
        //   ),
        // ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}
