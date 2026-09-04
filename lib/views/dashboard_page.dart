import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/authlistener.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/models/categories.dart';
import 'package:sevenup_mobile/state/auth/index.dart';
import 'package:sevenup_mobile/views/course/cubit/category_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/course_action_cubit.dart';
import 'package:sevenup_mobile/views/course/cubit/course_cubit.dart';
import 'package:sevenup_mobile/views/home_page.dart';

import 'login_page.dart';

/// Authentication guard + landing router.
///
/// - Unauthenticated -> Login (which runs the 2FA flow when required)
/// - Authenticated -> Home (service modules)
class DashboardPage extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return AuthListener(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (c, state) {
          if (state is UnAuthenticated) {
            return LoginPage(message: state.message);
          }
          return const HomePage();
        },
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String routeName;
  final String backgroundImage;

  DashboardItem(this.title, this.backgroundImage, this.routeName);
}

/// Category selection sheet (Figma 05A). Selection logic is unchanged; only the
/// presentation matches the approved design.
class CategoryDetailsDialog extends StatelessWidget {
  final Function(Categories course) action;
  const CategoryDetailsDialog({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseActionCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<CourseActionCubit, CourseActionState>(
            listener: (context, state) {
              if (state is CourseActionError) {
                // handled elsewhere
              }
            },
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.75,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTokens.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Categories',
                      style: AppTokens.manrope(
                          size: 24,
                          weight: 700,
                          color: AppTokens.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select one or more course categories',
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          color: AppTokens.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (var item in [
                            Categories(name: 'All', id: ''),
                            ...?context.watch<CategoryCubit>().state.data,
                          ])
                            _CategoryRow(
                              name: item.name,
                              selected: (context
                                          .watch<CategoryCubit>()
                                          .state
                                          .selected
                                          ?.id ??
                                      '') ==
                                  item.id,
                              onTap: () => context
                                  .read<CategoryCubit>()
                                  .selectCategory(item),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        onPressed: () {
                          context.read<CourseCubit>().loadCatalogue(
                                context.read<CategoryCubit>().state.selected,
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Apply filter',
                          style: AppTokens.manrope(
                              size: 15, weight: 600, color: Colors.white),
                        ),
                      ),
                    ),
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

class _CategoryRow extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryRow({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTokens.manrope(
                  size: 16,
                  weight: selected ? 600 : 400,
                  color: selected ? AppTokens.primary : AppTokens.textPrimary,
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTokens.primary : Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected ? AppTokens.primary : AppTokens.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
