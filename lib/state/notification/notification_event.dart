import 'package:flutter/foundation.dart';

@immutable
abstract class NotificationEvent {}

class DisplaySnackBar extends NotificationEvent {
  final String message;

  DisplaySnackBar(this.message);

  @override
  String toString() => 'DisplaySnackBar: $message';
}
