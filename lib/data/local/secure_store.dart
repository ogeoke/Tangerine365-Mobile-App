import 'package:flutter/foundation.dart';
// import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  // final SimpleSecureStorage storage;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool isInitialized = false;

  factory SecureStore() => SecureStore._();

  SecureStore._();
  // storage = SimpleSecureStorage();

  Future<void> init() async {
// await storage.
    isInitialized = true;
  }

  void setString(String key, String value) async {
    if (!isInitialized) await init();
    try {
      return await storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  Future<String?> getString(String key) async {
    if (!isInitialized) await init();

    try {
      return await storage.read(key: key);
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  Future<void> deleteKey(String key) async {
    if (!isInitialized) await init();

    await storage.delete(key: key);
  }
}
