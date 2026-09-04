import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/state/auth/auth_bloc.dart';
import 'package:sevenup_mobile/views/course/cubit/course_item_cubit.dart';
import 'package:sevenup_mobile/views/playcourse_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/env.dart';
import '../models/course.dart';
import '../models/course_item.dart';

class CourseItemList extends StatefulWidget {
  final Course course;
  const CourseItemList({super.key, required this.course});

  @override
  State<CourseItemList> createState() => _CourseItemListState();
}

class _CourseItemListState extends State<CourseItemList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseItemCubit, CourseItemState>(
      builder: (context, state) {
        if (state.isLoading && (state.data?.toList() ?? []).isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if ((state.data?.toList() ?? []).isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'No lessons here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
            ),
          );
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 20),
          shrinkWrap: true,
          itemCount: state.data?.length ?? 0,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: CourseItemCard(data: state.data![index]),
          ),
        );
      },
    );
  }
}

class CourseItemCard extends StatelessWidget {
  final CourseItem data;
  const CourseItemCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: CupertinoButton(
        minimumSize: const Size(1, 1),
        padding: EdgeInsets.zero,
        onPressed: () {
          if (data.proctoringEnabled == true) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Proctoring Enabled'),
                content: const Text(
                  'This lesson can only be played on a desktop. Please login on your computer to play this lesson.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got It'),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pop();
                  //     launchUrl(
                  //       _buildContentURi(data.idItem ?? '', data.src ?? ''),
                  //       mode: LaunchMode.externalApplication,
                  //     );
                  //   },
                  //   child: const Text('Proceed'),
                  // ),
                ],
              ),
            );
            return;
          }
          if (data.type == 'item') {
            launchUrl(
              _buildContentURi(
                data.idItem ?? '',
                data.src ?? '',
                data.idCourse ?? '',
              ),
              mode: LaunchMode.externalApplication,
            );
            return;
          }
          // launchUrl(_buildContentURi(data.idItem ?? '', data.src ?? ''),
          // webViewConfiguration: const WebViewConfiguration(
          //   enableDomStorage: true,
          //   enableJavaScript: true,
          //   headers: {},
          // ),
          // browserConfiguration: const BrowserConfiguration(
          //   showTitle: true
          // ),webOnlyWindowName: '',
          // mode: LaunchMode.platformDefault);
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (c) => PlayCoursePage(
                auth: GetIt.I<AuthBloc>().state.token ?? '',
                url: _buildContentURi(
                  data.idItem ?? '',
                  data.src ?? '',
                  data.idCourse ?? '',
                ),
              ),
            ),
          )
              .then((v) {
            // ignore: use_build_context_synchronously
            context.read<CourseItemCubit>().load();
          });
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AppTokens.primary),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: _PlayIcon(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTokens.manrope(
                          size: 14,
                          weight: 700,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Video lesson · ${_statusLabel(data.status)}',
                        style: AppTokens.manrope(
                          size: 11,
                          weight: 400,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _StatusCircle(status: data.status),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Uri _buildContentURi(String contentId, String src, String courseId) {
    var env = GetIt.I<Env>();
    var auth = GetIt.I<AuthBloc>();
    var uri = Uri.parse(
      '${env.baseUrl}$src&auth=${auth.state.token}&course_id=$courseId&source=mobile',
    );

    ///&key=${env.scormApiKey}
    // uri = uri.replace(queryParameters: <String, dynamic>{
    //   // 'key': env.scormApiKey,
    //   'modname': 'organization',
    //   'op': 'custom_playitem',
    //   'id_item': 1013,
    //   // 'username': auth.state.user?.username,
    //   'auth': auth.state.token,
    //   // 'course_id': '-1',
    //   // 'lesson_id': lessonId,
    //   // 'lesson_content_id': contentId
    // });
    print(uri.toString());
    return uri;
  }
}

String _statusLabel(CourseItemStatus status) {
  switch (status) {
    case CourseItemStatus.completed:
      return 'Completed';
    case CourseItemStatus.inProgress:
      return 'In progress';
    case CourseItemStatus.notStarted:
      return 'Not started';
  }
}

/// Green outlined play indicator on the left of each lesson row.
class _PlayIcon extends StatelessWidget {
  const _PlayIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppTokens.primary, width: 1.4),
      ),
      child: const Icon(Icons.play_arrow_rounded,
          color: AppTokens.primary, size: 20),
    );
  }
}

/// Lesson status indicator: red minus (Not Started), yellow dot (In Progress),
/// green check (Completed) — per the approved Figma design.
class _StatusCircle extends StatelessWidget {
  final CourseItemStatus status;
  const _StatusCircle({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final Widget mark;
    switch (status) {
      case CourseItemStatus.completed:
        color = AppTokens.statusCompleted;
        mark = const Icon(Icons.check, color: Colors.white, size: 18);
        break;
      case CourseItemStatus.inProgress:
        color = AppTokens.statusInProgress;
        mark = Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        );
        break;
      case CourseItemStatus.notStarted:
        color = AppTokens.statusNotStarted;
        mark = Container(
          width: 12,
          height: 2.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
        break;
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: mark,
    );
  }
}
