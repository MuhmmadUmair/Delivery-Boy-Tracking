import 'package:flutter/widgets.dart';

class GlobalUnfocusKeyboard extends StatelessWidget {
  const GlobalUnfocusKeyboard({
    required this.child,
    super.key,
  });

  final Widget child;

  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => hideKeyboard(context),
        child: child,
      );
}
