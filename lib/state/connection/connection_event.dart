import 'package:flutter/foundation.dart';

@immutable
abstract class ConnectionEvent {}

class ConnectionChanged extends ConnectionEvent {
  final ConnectionStatus status;

  ConnectionChanged(this.status);

  @override
  String toString() => '''
  ConnectionChanged : { status: $status }''';
}

enum ConnectionStatus { mobile, wifi, noConnection }
