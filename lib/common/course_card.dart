import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:sevenup_mobile/common/app_dialog.dart';
import 'package:sevenup_mobile/common/success_dialog.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/extensions/date.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/main.dart';
import 'package:sevenup_mobile/models/course.dart';
import 'package:sevenup_mobile/views/course/cubit/course_action_cubit.dart';
import 'package:sevenup_mobile/views/course_details.dart';

enum CourseAction { enroll, enter, subscribe, adminOnly }

extension Str on String {
  // capitalize first letter of a every word in a string
  String toTitleCase() {
    if (isEmpty) return this;
    List<String> s = toLowerCase().split(' ');
    String result = '';
    for (var e in s) {
      result += e.replaceRange(0, 1, e[0].toUpperCase());
      result += ' ';
    }
    return result.trim();
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final CourseAction action;
  // final Function
  const CourseCard(
      {super.key, required this.course, this.action = CourseAction.enter});

  @override
  Widget build(BuildContext context) {
    actionHandler() {
      switch (action) {
        case CourseAction.enter:
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (c) => CourseDetails(course: course)));
          return;
        case CourseAction.enroll:
          // Approval-required courses use the confirmation flow (11A/11B).
          showDialog(
              context: context,
              builder: (c) => RequestApprovalDialog(course: course));
          return;
        case CourseAction.subscribe:
          // Free courses (10A): self-subscribe directly, then enter the course.
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => SelfSubscribeDialog(course: course));
          return;
        case CourseAction.adminOnly:
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text(
                    'This course can only be assigned by an administrator.')));
          return;
      }
    }

    return Material(
      color: AppTokens.surface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.10),
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: InkWell(
        onTap: actionHandler,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: course.courseId ?? course.idCourse ?? '',
                child: SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: course.courseImage ?? course.imgCourse ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Container(color: AppTokens.lightGreen),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName ?? course.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                      size: 14,
                      weight: 700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Closing Date: ${DateTime.tryParse(course.subEndDate ?? '')?.format() ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTokens.manrope(
                      size: 11,
                      weight: 700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    switch (action) {
                      CourseAction.enter => 'Enter',
                      CourseAction.subscribe => 'Subscribe',
                      CourseAction.enroll => 'Request Approval',
                      CourseAction.adminOnly => 'Admin Only',
                    },
                    style: AppTokens.manrope(
                      size: 13,
                      weight: 600,
                      color: action == CourseAction.adminOnly
                          ? AppTokens.textSecondary
                          : AppTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Request-approval confirmation flow (Figma 11A → 11B). Uses the existing
/// CourseActionCubit.subscribe action; only the surrounding UI is new.
class RequestApprovalDialog extends StatelessWidget {
  final Course course;
  const RequestApprovalDialog({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseActionCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<CourseActionCubit, CourseActionState>(
            listener: (context, state) {
              if (state is CourseActionSuccess) {
                Navigator.of(context).pop();
                showDialog(
                  context: App.navigatorKey.currentContext!,
                  builder: (c) => const AppSuccessDialog(
                    title: 'Request sent',
                    message:
                        'Your course request has been sent to the administrator. You will be notified when it is approved.',
                    buttonLabel: 'Back to catalogue',
                  ),
                );
              }
              if (state is CourseActionError) {
                Navigator.of(context).pop();
                AppDialog.buildErrorDialog(
                    App.navigatorKey.currentContext!, state.error.message);
              }
            },
            child: AppConfirmDialog(
              title: 'Request approval?',
              message:
                  'Send an enrolment request for ${course.courseName ?? course.name ?? 'this course'} to your administrator?',
              cancelLabel: 'Cancel',
              confirmLabel: 'Send request',
              loading: context.watch<CourseActionCubit>().state
                  is CourseActionLoading,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () => context
                  .read<CourseActionCubit>()
                  .subscribe(course.courseId ?? course.idCourse ?? ''),
            ),
          );
        },
      ),
    );
  }
}

class CourseCardAlt extends StatelessWidget {
  final Course course;
  // final Function
  const CourseCardAlt({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    parseHtml(String html) {
      try {
        return parse(html).body?.text ?? '';
      } catch (e) {
        return '';
      }
    }

    return Material(
      color: Colors.white,
      elevation: 7,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (c) => CourseDetails(course: course)));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Hero(
                  tag: course.courseId ?? course.idCourse ?? '',
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(10)),
                    child: SizedBox(
                        width: 112,
                        height: 120,
                        child: CachedNetworkImage(
                          imageUrl:
                              course.courseImage ?? course.imgCourse ?? '',
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Material(
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                  ),
                )),
            const SizedBox(height: 9.0),
            Expanded(
                child: SizedBox(
                    height: 120,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(course.courseName ?? course.name ?? '',
                                  maxLines: 2,
                                  // overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              const SizedBox(height: 6.0),
                              Text(parseHtml(course.courseDescription ?? ''),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff8D9093))),
                              const SizedBox(height: 9.0),
                              Row(
                                children: [
                                  const Text('Closing Date: ',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 11.0,
                                          height: 1,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black)),
                                  const SizedBox(width: 5),
                                  Container(
                                      width: 1.3,
                                      height: 14,
                                      color: const Color(0xff333333)),
                                  const SizedBox(width: 5),
                                  Text(
                                      DateTime.tryParse(course.subEndDate ?? '')
                                              ?.format() ??
                                          'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11.0,
                                          height: 1,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black)),
                                ],
                              ),
                            ])))),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsDialog extends StatelessWidget {
  final CourseAction action;
  final Course course;
  const CourseDetailsDialog(
      {super.key, required this.course, required this.action});

  @override
  Widget build(BuildContext context) {
    parseHtml(String html) {
      try {
        return parse(html).body?.text ?? '';
      } catch (e) {
        return '';
      }
    }

    return BlocProvider(
      create: (context) => CourseActionCubit(),
      child: Builder(builder: (context) {
        return BlocListener<CourseActionCubit, CourseActionState>(
          listener: (context, state) {
            if (state is CourseActionSuccess) {
              Navigator.of(context).pop();
              if (action == CourseAction.enroll) {
                showDialog(
                    context: App.navigatorKey.currentContext!,
                    builder: (c) => SubscribeSuccessAlt(course: course));
                return;
              }
              // 10A: self-subscribe succeeded → show the transient success
              // popup, then take the student straight into the course (10B).
              showDialog(
                context: App.navigatorKey.currentContext!,
                barrierDismissible: false,
                builder: (c) => CatalogueSubscribeSuccess(course: course),
              ).then((_) {
                App.navigatorKey.currentState?.push(CupertinoPageRoute(
                    builder: (_) => CourseDetails(course: course)));
              });
            }

            if (state is CourseActionError) {
              AppDialog.buildErrorDialog(context, state.error.message);
            }
          },
          child: SizedBox(
              height: 500,
              width: double.infinity,
              child: Material(
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.0)),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course Details',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Material(
                          elevation: 6,
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: double.infinity,
                                  height: 120,
                                  child: CachedNetworkImage(
                                    imageUrl: course.courseImage ??
                                        course.imgCourse ??
                                        '',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Material(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          )),
                      const SizedBox(height: 11),
                      Text(
                        course.name ?? course.courseName ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 1),
                      Text(parseHtml(course.courseDescription ?? ''),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff545454).withOpacity(0.8))),
                      const SizedBox(height: 26),
                      const Spacer(),
                      CupertinoButton(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          context.read<CourseActionCubit>().subscribe(
                              course.courseId ?? course.idCourse ?? '');
                        },
                        padding: const EdgeInsets.symmetric(vertical: 10.0)
                            .copyWith(left: 22),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    action == CourseAction.enroll
                                        ? 'Enroll now'
                                        : 'I’m Interested in this course',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))),
                            Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: context.watch<CourseActionCubit>().state
                                        is CourseActionLoading
                                    ? SizedBox.square(
                                        dimension: 19,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Theme.of(context).primaryColor,
                                        ))
                                    : Assets.svg.rightArrow.svg(
                                        height: 17,
                                        width: 21,
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context).primaryColor,
                                            BlendMode.srcIn)),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )),
        );
      }),
    );
  }
}

/// Runs a direct self-subscribe (free courses, Figma 10A): shows a brief
/// spinner while subscribing, then the success popup + opens the course (10B).
class SelfSubscribeDialog extends StatelessWidget {
  final Course course;
  const SelfSubscribeDialog({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseActionCubit()
        ..subscribe(course.courseId ?? course.idCourse ?? ''),
      child: Builder(
        builder: (context) {
          return BlocListener<CourseActionCubit, CourseActionState>(
            listener: (context, state) {
              if (state is CourseActionSuccess) {
                Navigator.of(context).pop(); // close spinner
                showDialog(
                  context: App.navigatorKey.currentContext!,
                  barrierDismissible: false,
                  builder: (c) => CatalogueSubscribeSuccess(course: course),
                ).then((_) {
                  App.navigatorKey.currentState?.push(CupertinoPageRoute(
                      builder: (_) => CourseDetails(course: course)));
                });
              }
              if (state is CourseActionError) {
                Navigator.of(context).pop();
                AppDialog.buildErrorDialog(
                    App.navigatorKey.currentContext!, state.error.message);
              }
            },
            child: Dialog(
              backgroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppTokens.primary),
                    const SizedBox(height: 18),
                    Text('Subscribing…',
                        style: AppTokens.manrope(
                            size: 15,
                            weight: 600,
                            color: AppTokens.textPrimary)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Catalogue self-subscribe success popup (Figma 10A): green check,
/// "Subscription successful" and the course name. No button — it auto-dismisses
/// and the caller then opens the course content (10B).
class CatalogueSubscribeSuccess extends StatefulWidget {
  final Course course;
  const CatalogueSubscribeSuccess({super.key, required this.course});

  @override
  State<CatalogueSubscribeSuccess> createState() =>
      _CatalogueSubscribeSuccessState();
}

class _CatalogueSubscribeSuccessState extends State<CatalogueSubscribeSuccess> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.course.courseName ?? widget.course.name ?? 'the course';
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.lightGreen,
              ),
              child:
                  const Icon(Icons.check, color: AppTokens.primary, size: 48),
            ),
            const SizedBox(height: 22),
            Text('Subscription successful',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 24, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 10),
            Text('You are now subscribed to $name.',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 14,
                    weight: 400,
                    height: 20,
                    color: AppTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class SubscribeSuccess extends StatelessWidget {
  const SubscribeSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.lightGreen,
              ),
              child:
                  const Icon(Icons.check, color: AppTokens.primary, size: 40),
            ),
            const SizedBox(height: 18),
            Text('Congratulations',
                style: AppTokens.manrope(
                    size: 22, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 8),
            Text('Your course request has been sent to the administrator.',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 13,
                    weight: 400,
                    height: 20,
                    color: AppTokens.textSecondary)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Done',
                    style: AppTokens.manrope(
                        size: 15, weight: 600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscribeSuccessAlt extends StatelessWidget {
  final Course course;
  const SubscribeSuccessAlt({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.lightGreen,
              ),
              child:
                  const Icon(Icons.check, color: AppTokens.primary, size: 40),
            ),
            const SizedBox(height: 18),
            Text('Subscription successful',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 22, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 8),
            Text('You have been successfully assigned to this course.',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 13,
                    weight: 400,
                    height: 20,
                    color: AppTokens.textSecondary)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  App.navigatorKey.currentState?.push(CupertinoPageRoute(
                      builder: (c) => CourseDetails(course: course)));
                },
                child: Text('View course',
                    style: AppTokens.manrope(
                        size: 15, weight: 600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
