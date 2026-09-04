import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sevenup_mobile/common/notification_listener.dart';
import 'package:sevenup_mobile/common/page_scaffold.dart';
import 'package:sevenup_mobile/services/knowledge_provider.dart';

class KnowledgeRepo extends StatefulWidget {
  static const routeName = '/knowledge';
  const KnowledgeRepo({super.key});
  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<KnowledgeRepo> {
  late KnowledgeProvider _provider;
  @override
  void initState() {
    _provider = KnowledgeProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _provider,
      child: PageScaffold(
        parent: SmartRefresher(
          // enablePullDown: true,
          scrollController: _provider.scrollController,
          controller: _provider.refreshController,
          onRefresh: _provider.onRefresh,
        ),
        content: KNotificationListener(
          child: Consumer<KnowledgeProvider>(
            builder: (context, state, _) =>
                // SmartRefresher(
                //   enablePullDown: true,
                //   header: MaterialClassicHeader(),
                //   controller: _provider.refreshController,
                //   onRefresh: _provider.onRefresh,
                //   child:
                _provider.data == null
                    ? const SizedBox.shrink()
                    : _provider.length > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ListView.builder(
                              itemCount: _provider.length,
                              itemBuilder: (c, i) {
                                var item = _provider.data?.entries.toList()[i];
                                return ExpansionTile(
                                  title: Text(item?.key ?? ''),
                                  children: [..._buildSubCategory(item?.value)],
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Text('Could not load knowledge repositrory'),
                          ),
          ),
        ),
      ),
    );
  }

  List<Repo> _buildRepo(List<dynamic> item) =>
      item.map<Repo>((e) => Repo.fromJson(e)).toList();

  List<Widget> _buildSubCategory(Map<String, dynamic> item) {
    var result = <Widget>[];
    for (var i in item.entries) {
      if (i.value is List) {
        result.add(
          Column(
            children: [
              const Divider(),
              ListTile(
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (c) =>
                        KnowledgeRepoDetails(repo: _buildRepo(i.value)),
                    settings: const RouteSettings(
                      name: KnowledgeRepoDetails.routeName,
                    ),
                  ),
                ),
                title: Text(i.key),
              ),
            ],
          ),
        );
      }
    }
    return result;
  }
}

class KnowledgeRepoDetails extends StatefulWidget {
  static const routeName = '/knowledge-details';
  const KnowledgeRepoDetails({super.key, required this.repo});
  final List<Repo> repo;
  @override
  KnowledgeRepoDetailsState createState() => KnowledgeRepoDetailsState();
}

class KnowledgeRepoDetailsState extends State<KnowledgeRepoDetails> {
  late KnowledgeProvider _provider;
  @override
  void initState() {
    _provider = KnowledgeProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _provider,
      child: PageScaffold(
        // parent: SmartRefresher(
        //   enablePullDown: true,
        //   scrollController: _provider.scrollController,
        //   controller: _provider.refreshController,
        //   onRefresh: _provider.onRefresh,
        // ),
        backButton: const BackButton(),
        content: KNotificationListener(
          child: widget.repo.isNotEmpty
              ? ListView.builder(
                  itemCount: widget.repo.length,
                  itemBuilder: (c, i) {
                    var item = widget.repo[i];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.subCategory),
                          onTap: () => showCupertinoDialog(
                            context: context,
                            builder: (c) => CupertinoPopupSurface(
                              isSurfacePainted: true,
                              child: Scaffold(
                                // backgroundColor: c,
                                body: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: Stack(
                                    children: [
                                      SingleChildScrollView(
                                        child: SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                // HtmlWidget(
                                                //     item.description)),
                                                Html(
                                              data: item.description,
                                              // extensions: [
                                              //   TagExtension(
                                              //     tagsToExtend: {"flutter"},
                                              //     child: const FlutterLogo(),
                                              //   ),
                                              // ],
                                              style: {
                                                "p.fancy": Style(
                                                  textAlign: TextAlign.center,
                                                  padding: HtmlPaddings.all(
                                                    16,
                                                  ),
                                                  backgroundColor: Colors.grey,
                                                  margin: Margins(
                                                    left: Margin(
                                                      50,
                                                      Unit.px,
                                                    ),
                                                    right: Margin.auto(),
                                                  ),
                                                  width: Width(
                                                    300,
                                                    Unit.px,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 10,
                                        child: IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            //  AppDialog(
                            //   useHtml: true,
                            //   message: item.description,
                            //   title: item.title,
                            // ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                )
              : const Center(child: Text('No data in this sub category')),
        ),
      ),
    );
  }
}

class Repo {
  final String title, subCategory, description, category;

  Repo({
    required this.title,
    required this.subCategory,
    required this.description,
    required this.category,
  });
  factory Repo.fromJson(Map<String, dynamic> json) => Repo(
        title: json['title'],
        subCategory: json['sub_category'],
        description: json['description'],
        category: json['category'],
      );
}
