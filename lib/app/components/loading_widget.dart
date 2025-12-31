import 'dart:io' show Platform;

import 'package:firebase_google_apple_notif/app/styles/theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.size = 32.0, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.primary;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Platform.isIOS
            ? CupertinoActivityIndicator(color: effectiveColor)
            : CircularProgressIndicator(strokeWidth: 2, color: effectiveColor),
      ),
    );
  }
}
