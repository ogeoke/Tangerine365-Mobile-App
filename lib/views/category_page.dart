// import 'package:built_collection/built_collection.dart';
// import 'package:sevenup_mobile/common/page_scaffold.dart';
// import 'package:sevenup_mobile/models/categories.dart';
// import 'package:sevenup_mobile/models/course_item.dart';
// import 'package:sevenup_mobile/state/my_provider.dart';
// import 'package:sevenup_mobile/views/courses_page.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

// import '../data/api_repository.dart';
// import 'dashboard_page.dart';

// class CategoryPage extends StatefulWidget {
//   static const routeName = '/categories';
//   CategoryPage({super.key, required DashboardItem item})
//       : item =
//             DashboardItem('CATEGORIES', item.backgroundImage, item.routeName);
//   final DashboardItem item;
//   @override
//   CategoryPageState createState() => CategoryPageState();
// }

// class CategoryPageState extends State<CategoryPage> {
//   late CategoryProvider _provider;
//   @override
//   void initState() {
//     _provider = CategoryProvider();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (_) => _provider,
//         child: PageScaffold(
//             title: 'Categories',
//             parent: SmartRefresher(
//                 enablePullDown: true,
//                 // scrollController: _provider.scrollController,
//                 controller: _provider.refreshController,
//                 onRefresh: _provider.onRefresh),
//             backButton: const BackButton(),
//             content: ListView(
//               children: <Widget>[
//                 Consumer<CategoryProvider>(
//                     builder: (context, state, _) => Column(
//                           children: <Widget>[
//                             _provider.categories == null
//                                 ? SizedBox.shrink(
//                                     child: state.initializing
//                                         ? null
//                                         : Container(
//                                             alignment: Alignment.center,
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: const Text(
//                                               'Could not load Categories, pull down page to refresh',
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                   fontSize: 18,
//                                                   letterSpacing: 0.02),
//                                             )))
//                                 : _provider.categories?.isNotEmpty == true
//                                     ? Container(
//                                         padding: const EdgeInsets.only(
//                                             bottom: 5.0,
//                                             top: 50,
//                                             right: 20,
//                                             left: 20),
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: <Widget>[
//                                             for (var i
//                                                 in _provider.categories ??
//                                                     List<Categories>())
//                                               _buildCategoryCard(i),
//                                           ],
//                                         ))
//                                     : const Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: <Widget>[
//                                           Icon(
//                                             Icons.info,
//                                             color: Colors.red,
//                                             size: 70,
//                                           ),
//                                           Text(
//                                             'No Assigned Categories',
//                                             style: TextStyle(
//                                                 color: Colors.red,
//                                                 fontSize: 20,
//                                                 letterSpacing: 0.02,
//                                                 fontWeight: FontWeight.w600),
//                                           ),
//                                         ],
//                                       ),
//                           ],
//                         )),
//               ],
//             )));
//   }

//   // Category category
//   Widget _buildCategoryCard(Categories category) => Card(
//         elevation: 0,
//         clipBehavior: Clip.antiAlias,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
//           // side: BorderSide(
//           //     color: Theme.of(context).primaryColor.withOpacity(0.1),
//           //     width: 1)
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 10),
//         child: InkWell(
//           onTap: () => Navigator.of(context).push(CupertinoPageRoute(
//               builder: (c) => CoursesPage(
//                   item: CourseItem([category.name], widget.item.backgroundImage,
//                       category.id.toString(),
//                       isLesson: false)))),
//           // arguments: CourseItem([category.name],
//           //     widget.item.backgroundImage, category.id.toString())),
//           child: Ink(
//             color: Theme.of(context).primaryColor.withOpacity(0.09),
//             padding: const EdgeInsets.only(right: 20),
//             child: Row(
//               children: <Widget>[
//                 Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   color: Theme.of(context).primaryColor,
//                   width: 7,
//                   height: 60,
//                 ),
//                 Expanded(
//                   child: Text(
//                     category.name,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ),
//                 // Spacer(),
//                 Icon(
//                   Icons.arrow_right,
//                   color: Theme.of(context).primaryColor.withOpacity(0.8),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
// }

// class CategoryProvider extends MyProvider {
//   List<Categories>? categories;
//   final _repository = ApiRepository();

//   bool initializing = true;

//   @override
//   Future<void> onRefresh() async {
//     useCache = false;
//     loadCategory();
//   }

//   Future<void> loadCategory() async {
//     // print('refreshing categories ${refreshController.isRefresh}');
//     final response = await _repository.getCategories();
//     if (response.body is List<Categories>) {
//       categories = response.body;
//     }
//     refreshController.refreshCompleted();
//     initializing = false;
//     notify(categories);
//   }
// }
