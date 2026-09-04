import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class MyProvider with ChangeNotifier {
  bool useCache = true;
  dynamic currentState;

  /// scroll controller
  final ScrollController scrollController = ScrollController();

  /// refresh controller to use with Smart refresh
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );

  /// handles refreshing the page
  Future<void> onRefresh();

  /// logs the current state and new state
  void notify(state) {
    super.notifyListeners();
    if (kDebugMode) {
      print('''$runtimeType { 
            currentState: ${currentState?.toString()}, 
            nextState: ${state?.toString()} 
            }''');
    }
    currentState = state;
  }
}
