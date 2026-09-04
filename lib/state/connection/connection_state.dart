import 'package:equatable/equatable.dart';

import 'connection_event.dart';

class ConnectionState extends Equatable {
  final ConnectionStatus status;

  const ConnectionState(this.status);

  @override
  List<Object> get props => ([status]);

  @override
  String toString() => '''ConnectionState: { status: $status }''';
}
