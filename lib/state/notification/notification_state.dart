import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  final String? message;

  const NotificationState(this.message);

  @override
  List<Object?> get props => ([message]);

  @override
  String toString() => 'NotificationState';
}

class NotificationMessage extends NotificationState {
  const NotificationMessage(super.message);

  @override
  String toString() => 'NotificationMessage';
}

class NotificationEmpty extends NotificationState {
  const NotificationEmpty() : super(null);

  @override
  String toString() => 'NotificationEmpty';
}
