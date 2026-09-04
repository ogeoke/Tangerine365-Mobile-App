import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sevenup_mobile/common/course_card.dart';
import 'package:sevenup_mobile/common/course_state_card.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/views/course_grid.dart';

import 'course/cubit/category_cubit.dart';
import 'course/cubit/course_cubit.dart';
import 'dashboard_page.dart';

/// Catalogue state of the Courses Hub (Figma 05). Presentation only — the
/// category filtering and course actions are unchanged.
class CourseCataloguePage extends StatelessWidget {
  final CourseAction action;
  const CourseCataloguePage({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<CategoryCubit>().state.selected;
    final hasSelection = (selected?.id ?? '').isNotEmpty;
    final count = context.watch<CourseCubit>().state.courses?.length ?? 0;
    return Column(
      children: [
        if (action == CourseAction.subscribe)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding, 4, AppTokens.screenPadding, 8),
            child: _FilterRow(
              selectedName: hasSelection ? selected?.name : null,
              onTap: () {
                context.read<CategoryCubit>().load();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (c) => CategoryDetailsDialog(action: (course) {}),
                );
              },
            ),
          ),
        if (hasSelection)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding, 6, AppTokens.screenPadding, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${selected?.name} courses',
                    style: AppTokens.manrope(
                      size: 18,
                      weight: 700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$count course${count == 1 ? '' : 's'}',
                  style: AppTokens.manrope(
                    size: 12,
                    weight: 400,
                    color: AppTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        Builder(
          builder: (context) {
            final s = context.watch<CourseCubit>().state;
            final list = s.courses;
            // Catalogue states (Figma: Catalogue — Loading / Empty / Error).
            if (s.isLoading && list == null) {
              return const CourseStateCard(
                state: CourseCardState.loading,
                title: 'Loading catalogue…',
                message: 'Courses and recommendations will appear shortly.',
              );
            }
            if (s.hasError && (list == null || list.isEmpty)) {
              return CourseStateCard(
                state: CourseCardState.error,
                title: "Couldn't load catalogue",
                message: 'Check your connection and retry.',
                onRetry: () => context
                    .read<CourseCubit>()
                    .loadCatalogue(context.read<CategoryCubit>().state.selected),
              );
            }
            if (list != null && list.isEmpty) {
              return const CourseStateCard(
                state: CourseCardState.empty,
                title: 'No catalogue courses',
                message: 'New catalogue courses will appear here.',
              );
            }
            return CourseGrid(action: action);
          },
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String? selectedName;
  final VoidCallback onTap;
  const _FilterRow({required this.selectedName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffEDF2ED),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.tune, color: AppTokens.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter courses',
                      style: AppTokens.manrope(
                        size: 15,
                        weight: 700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    Text(
                      selectedName ?? 'Choose one or more categories',
                      style: AppTokens.manrope(
                        size: 12,
                        weight: selectedName != null ? 600 : 400,
                        color: selectedName != null
                            ? AppTokens.primary
                            : AppTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTokens.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
