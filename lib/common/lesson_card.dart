// import 'package:sevenup_mobile/common/units_tile.dart';
// import 'package:sevenup_mobile/models/course.dart';
// import 'package:sevenup_mobile/models/course_item.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LessonCard extends StatelessWidget {
//   final Course course;
//   final UnitsProvider _unitsProvider;
//   final UnitsProvider _testsProvider;
//   final CourseItem item;

//   LessonCard({super.key, required this.course, required this.item})
//       : _unitsProvider = UnitsProvider(course.lessonId.toString()),
//         _testsProvider =
//             UnitsProvider(course.lessonId.toString(), isTest: true);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: Ink(
//           child: Column(
//         children: <Widget>[
//           Container(
//             color: Theme.of(context).primaryColor.withOpacity(0.09),
//             padding: const EdgeInsets.only(right: 20),
//             child: Row(
//               children: <Widget>[
//                 Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   color: Theme.of(context).primaryColor.withOpacity(0.5),
//                   width: 7,
//                   height: 60,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     course.lessonName ?? '',
//                     style: const TextStyle(
//                         fontSize: 15,
//                         letterSpacing: 0.06,
//                         fontWeight: FontWeight.w600),
//                     maxLines: 4,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 course.completed
//                     ? const Icon(
//                         Icons.check_circle,
//                         size: 20,
//                         color: Colors.green,
//                       )
//                     : const SizedBox.shrink(),
//               ],
//             ),
//           ),
//           ChangeNotifierProvider(
//               create: (_) => _unitsProvider,
//               child: const UnitsTile(
//                 title: 'UNITS',
//               )),
//           ChangeNotifierProvider(
//               create: (_) => _testsProvider,
//               child: const UnitsTile(
//                 title: 'TEST',
//               )),
//         ],
//       )),
//     );
//   }
// }

// // https://elearning.unionbankng.com/ubank/www/external_scorm_player.php?key=q2Zvs7IWwVHZ0kgcAM8758x&username=user&token=OGZlYWVlMTgyMmNmZTkzNDllNGMyMzA3YWI3MTExODU=&course_id=109&lesson_id=347&lesson_content_id=464
