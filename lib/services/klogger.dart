import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class KLogger {
  /// used by chopper to format logs
  static void setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      if (kDebugMode) {
        print('${rec.level.name}: ${rec.time}: ${rec.message}');
      }
    });
  }

  static void error(String message,
          {String? className, StackTrace? stackTrace}) =>
      Logger(className ?? 'Default').severe(message, stackTrace);
  static void info(String message,
          {String? className, StackTrace? stackTrace}) =>
      Logger(className ?? 'Default').info(message, stackTrace);
  static void success(String message,
          {String? className, StackTrace? stackTrace}) =>
      Logger(className ?? 'Default').fine(message);
}
