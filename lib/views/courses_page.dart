// import 'package:built_collection/built_collection.dart';
// import 'package:sevenup_mobile/common/course_card.dart';
// import 'package:sevenup_mobile/common/lesson_card.dart';
// import 'package:sevenup_mobile/common/page_scaffold.dart';
// import 'package:sevenup_mobile/constants/course_category.dart';
// import 'package:sevenup_mobile/models/course.dart';
// import 'package:sevenup_mobile/models/course_item.dart';
// import 'package:sevenup_mobile/state/courses_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

// class CoursesPage extends StatefulWidget {
//   static const routeName = '/courses';
//   const CoursesPage({super.key, required this.item});
//   final CourseItem item;
//   @override
//   CoursesPageState createState() => CoursesPageState();
// }

// class CoursesPageState extends State<CoursesPage> {
//   late CoursesProvider _provider;
//   @override
//   void initState() {
//     _provider =
//         CoursesProvider(widget.item.courseId, isLesson: widget.item.isLesson);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (_) => _provider,
//         child: PageScaffold(
//             parent: SmartRefresher(
//               enablePullDown: true,
//               scrollController: _provider.scrollController,
//               controller: _provider.refreshController,
//               onRefresh: _provider.onRefresh,
//             ),
//             // item: DashboardItem(
//             //     widget.item.isLesson ? 'MY LESSONS' : 'MY COURSES',
//             //     widget.item.backgroundImage,
//             //     widget.item.courseId),
//             backButton: const BackButton(),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(20),
//               child: Consumer<CoursesProvider>(
//                   builder: (context, state, _) =>
//                       _provider.course?.isNotEmpty == true
//                           ? Container(
//                               color: Colors.white,
//                               child: Container(
//                                 padding: const EdgeInsets.only(left: 20),
//                                 alignment: Alignment.centerLeft,
//                                 color: Theme.of(context).primaryColor,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Text(
//                                       '${_provider.course?.length ?? 0} courses / Lessons Available',
//                                       style: const TextStyle(
//                                           color: Colors.white,
//                                           letterSpacing: 0.01,
//                                           fontWeight: FontWeight.w600)),
//                                 ),
//                               ),
//                             )
//                           : const SizedBox.shrink()),
//             ),
//             content: Stack(
//               children: <Widget>[
//                 ListView(
//                   shrinkWrap: true,
//                   controller: _provider.scrollController,
//                   children: <Widget>[
//                     const SizedBox(height: 40),
//                     Consumer<CoursesProvider>(
//                         builder: (context, state, _) =>
//                             // _provider.course == null
//                             //     ? const SizedBox.shrink()
//                             (_provider.course?.isNotEmpty ?? false) == false
//                                 ? state.isLoading
//                                     ? const Center(
//                                         child: CupertinoActivityIndicator(),
//                                       )
//                                     : const Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: <Widget>[
//                                           SizedBox(height: 100),
//                                           Icon(
//                                             Icons.info,
//                                             color: Colors.red,
//                                             size: 70,
//                                           ),
//                                           Text(
//                                             'No Lessons for selected course',
//                                             style: TextStyle(
//                                                 color: Colors.red,
//                                                 fontSize: 15,
//                                                 letterSpacing: 0.02,
//                                                 fontWeight: FontWeight.w400),
//                                           ),
//                                         ],
//                                       )
//                                 : Container(
//                                     padding: const EdgeInsets.only(
//                                         bottom: 5.0,
//                                         top: 15,
//                                         right: 20,
//                                         left: 20),
//                                     child: Column(
//                                       children: <Widget>[
//                                         for (var i
//                                             in _provider.course ?? List())
//                                           _buildCoursesCard(i),
//                                       ],
//                                     ))),
//                   ],
//                 ),
//                 Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: const EdgeInsets.all(20),
//                     color: Theme.of(context).primaryColor.withOpacity(0.07),
//                     // alignment: Alignment.centerLeft,
//                     child: RichText(
//                         text: TextSpan(children: [
//                       for (var item in widget.item.steps)
//                         TextSpan(
//                             text: item,
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w600),
//                             children: [
//                               TextSpan(
//                                   text: (widget.item.steps.indexOf(item)) >
//                                           ((widget.item.steps.length) - 2)
//                                       ? ''
//                                       : '     ---->         ',
//                                   style: const TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: -01))
//                             ])
//                     ]))),
//               ],
//             )));
//   }

//   // Courses Courses
//   Widget _buildCoursesCard(Course course) {
//     switch (course.type) {
//       case Coursecategory.course:
//         return CourseCard(
//           course: course,
//           image: widget.item.backgroundImage,
//           item: widget.item,
//         );

//       case Coursecategory.lesson:
//         return LessonCard(
//           course: course,
//           item: widget.item,
//         );

//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
