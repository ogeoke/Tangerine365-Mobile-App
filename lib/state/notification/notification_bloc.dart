import 'package:sevenup_mobile/state/notification/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // todo: check singleton for logic in project
  static final NotificationBloc _notificationBlocSingleton =
      NotificationBloc._internal();
  factory NotificationBloc() {
    return _notificationBlocSingleton;
  }
  NotificationBloc._internal() : super(const NotificationEmpty()) {
    on<DisplaySnackBar>((event, emit) {
      emit(const NotificationEmpty());
      emit(NotificationMessage(event.message));
    });
  }
}
