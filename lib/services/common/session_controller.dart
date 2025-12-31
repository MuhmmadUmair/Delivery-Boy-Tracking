import 'package:flutter/material.dart';

class SessionController extends ChangeNotifier {
  String? _token;
  String? get token => _token;
}
