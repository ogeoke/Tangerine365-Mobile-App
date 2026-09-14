import 'dart:convert';

import 'package:data_repository/data_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveRepository implements LocalRepository {
  late LazyBox cacheBox;
  late LazyBox cacheTimeBox;
  static const _keyName = 'hive_cache_encryption_key';

  HiveRepository() {
    init();
  }

  /// AES key for the cache, generated once and kept in the OS-encrypted
  /// keystore (never on disk in the clear).
  Future<List<int>> _encryptionKey() async {
    const store = FlutterSecureStorage();
    final existing = await store.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) {
      try {
        return base64Url.decode(existing);
      } catch (_) {/* fall through and regenerate */}
    }
    final key = Hive.generateSecureKey();
    await store.write(key: _keyName, value: base64Url.encode(key));
    return key;
  }

  Future<LazyBox> _openEncrypted(String name, HiveAesCipher cipher) async {
    try {
      return await Hive.openLazyBox(name, encryptionCipher: cipher);
    } catch (_) {
      // A pre-existing unencrypted (or key-mismatched) box can't be opened
      // with a cipher. The cache is disposable, so reset it and reopen.
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openLazyBox(name, encryptionCipher: cipher);
    }
  }

  @override
  Future init() async {
    final cipher = HiveAesCipher(await _encryptionKey());
    cacheBox = await _openEncrypted('cache-box', cipher);
    cacheTimeBox = await _openEncrypted('cache-time-box', cipher);
    isInitialized = true;
  }

  @override
  Future getData(String key) async {
    if (!isInitialized) await init();

    return cacheBox.get(key);
  }

  @override
  Future<dynamic> saveData(String key, String data) async {
    if (!isInitialized) await init();
    cacheBox.put(key, data);
  }

  @override
  Future<bool> checkCache(String key) async {
    if (!isInitialized) await init();
    var time = await cacheTimeBox.get(key);
    if (time == null) return false;
    // return
    try {
      return !(time as int).isPast;
    } catch (e) {
      return false;
    }
  }

  @override
  void saveTime(String? key, int? duration) async {
    if (!isInitialized) await init();
    // duration = duration?.secondsToMilliseconds;
    if (key != null && key.isNotEmpty && duration != null && !duration.isNaN) {
      cacheTimeBox.put(key, duration);
    }
  }

  @override
  void clearCache() async {
    if (!isInitialized) await init();
    cacheBox.clear();
    cacheTimeBox.clear();
  }

  @override
  Future<int?> getTime(String key) async {
    if (!isInitialized) await init();
    return cacheTimeBox.get(key).asInt;
  }

  @override
  void removeData(String key) async {
    if (!isInitialized) await init();
    cacheBox.delete(key);
    cacheTimeBox.delete(key);
  }

  @override
  bool isInitialized = false;
}
