// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:sevenup_mobile/state/connection/index.dart';

// class ConnectivityManager {
//   static Future<bool> getStatus() async {
//     return true;
//     // print(await Connectivity().checkConnectivity());
//     // return ((await Connectivity().checkConnectivity()) !=
//     //     ConnectivityResult.none);
//   }

//   /// listens for changes in internet connection and publishes result
//   static Future listen() async =>
//       Connectivity().onConnectivityChanged.listen((state) {
//         ConnectionBloc().add(ConnectionChanged(_equateState(state)));
//       });

//   static _equateState(List<ConnectivityResult> state) {
//     switch (state.firstOrNull) {
//       case ConnectivityResult.wifi:
//         return ConnectionStatus.wifi;
//       case ConnectivityResult.mobile:
//         return ConnectionStatus.mobile;
//       default:
//         return ConnectionStatus.noConnection;
//     }
//   }
// }
