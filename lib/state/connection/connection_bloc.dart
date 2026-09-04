import 'package:sevenup_mobile/state/connection/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  static final ConnectionBloc _connectionBlocSingleton =
      ConnectionBloc._internal();
  factory ConnectionBloc() {
    return _connectionBlocSingleton;
  }
  ConnectionBloc._internal()
      : super(const ConnectionState(ConnectionStatus.noConnection)) {
    on<ConnectionChanged>((event, emit) {
      emit(ConnectionState(event.status));
    });
  }
}
