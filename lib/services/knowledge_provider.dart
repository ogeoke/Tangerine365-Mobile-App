import 'package:sevenup_mobile/state/my_provider.dart';

import '../data/api_repository.dart';

class KnowledgeProvider extends MyProvider {
  Map<String, dynamic>? data;
  final _repository = ApiRepository();

  int get length => data?.keys.length ?? 0;

  @override
  Future<void> onRefresh() async {
    useCache = false;
    load();
  }

  Future<void> load() async {
    final response = await _repository.getKnowledgeRepo(useCache);
    data = response.body;

    refreshController.refreshCompleted();
    notify(data);
  }
}
