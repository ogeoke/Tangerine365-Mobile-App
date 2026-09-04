import 'package:sevenup_mobile/models/faq.dart';

import '../data/api_repository.dart';
import 'my_provider.dart';

class FaqProvider extends MyProvider {
  List<Faq>? faq;
  final _repository = ApiRepository();

  @override
  Future<void> onRefresh() async {
    useCache = false;
    loadFaq();
  }

  Future<void> loadFaq() async {
    final response = await _repository.getFaq(useCache);
    if (response.body is List<Faq>) faq = response.body;
    refreshController.refreshCompleted();
    notify(faq);
  }
}
