import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// The state a course list can be in while it has no rows to show.
enum CourseCardState { loading, empty, error }

/// Centered white status card used by the My Courses / Catalogue / recommendation
/// lists (Figma 03D loading, 03E empty, 03F error). Optionally shows a Retry.
class CourseStateCard extends StatelessWidget {
  final CourseCardState state;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const CourseStateCard({
    super.key,
    required this.state,
    required this.title,
    required this.message,
    this.onRetry,
  });

  const CourseStateCard.loading({Key? key})
      : this(
          key: key,
          state: CourseCardState.loading,
          title: 'Loading courses...',
          message: 'This should only take a moment.',
        );

  const CourseStateCard.empty({
    Key? key,
    String title = 'No courses yet',
    String message = 'New learning will appear here.',
  }) : this(
          key: key,
          state: CourseCardState.empty,
          title: title,
          message: message,
        );

  const CourseStateCard.error({Key? key, VoidCallback? onRetry})
      : this(
          key: key,
          state: CourseCardState.error,
          title: "Couldn't load courses",
          message: 'Check your connection and retry.',
          onRetry: onRetry,
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPadding, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Mark(state: state),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 22, weight: 700, color: AppTokens.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 14, weight: 400, height: 20, color: AppTokens.textSecondary),
            ),
            if (state == CourseCardState.error && onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onRetry,
                child: Text('Retry',
                    style: AppTokens.manrope(
                        size: 14, weight: 700, color: AppTokens.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  final CourseCardState state;
  const _Mark({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case CourseCardState.loading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  color: AppTokens.primary, shape: BoxShape.circle),
            ),
          ),
        );
      case CourseCardState.empty:
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTokens.primary, width: 2),
          ),
        );
      case CourseCardState.error:
        return const Icon(Icons.close,
            color: AppTokens.statusNotStarted, size: 30);
    }
  }
}
