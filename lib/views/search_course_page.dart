import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/views/course/cubit/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'course/cubit/course_cubit.dart';
import 'course_list.dart';
import 'my_courses_page.dart';

class SearchCoursePage extends StatelessWidget {
  const SearchCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => CourseCubit()),
      ],
      child: Scaffold(
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
          leadingWidth: 50,
          centerTitle: false,
          title: Builder(builder: (context) {
            return TextFormField(
              onChanged: (q) {
                context.read<SearchCubit>().setSearch(q);
                context.read<CourseCubit>().search(q);
              },
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Color(0xffA0A4AB),
                  )),
            );
          }),
        ),
        body: Builder(builder: (context) {
          return context.watch<SearchCubit>().state.isEmpty
              ? const Center(
                  child: Text('Please type something',
                      style: TextStyle(fontSize: 18, color: Colors.black)))
              : CourseList(
                  courseCubit: context.read<CourseCubit>(),
                  myCourseType: MyCourseType.searchCourse,
                );
        }),
      ),
    );
  }
}
