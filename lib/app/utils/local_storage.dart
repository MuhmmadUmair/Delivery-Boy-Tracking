import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A class for managing local storage using FlutterSecureStorage.
class LocalStorage {
  final storage = const FlutterSecureStorage();

  /// Sets a key-value pair securely.
  Future<bool> setValue(String key, String value) async {
    await storage.write(key: key, value: value);
    return true;
  }

  /// Reads a value for the given key.
  Future<String?> readValue(String key) async {
    return storage.read(key: key);
  }

  /// Deletes a value for the given key.
  Future<bool> clearValue(String key) async {
    await storage.delete(key: key);
    return true;
  }
}
