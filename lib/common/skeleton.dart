import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Shimmering placeholder used while a list is loading. Mirrors the shape of an
/// "icon + two lines" card row (Messages, Announcements, rate tables, form
/// categories). A single [Shimmer] wraps the whole column so the sweep is
/// unified and cheap.
class SkeletonCards extends StatelessWidget {
  final int count;
  const SkeletonCards({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding, 12, AppTokens.screenPadding, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const _CardSkeleton(),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(48, 48, 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(double.infinity, 15, 6),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  alignment: Alignment.centerLeft,
                  child: _box(double.infinity, 12, 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmering placeholder for the NAFEX-style rate table (leading currency +
/// code, two right-aligned figures).
class SkeletonTableRows extends StatelessWidget {
  final int count;
  const SkeletonTableRows({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
            AppTokens.screenPadding, 0, AppTokens.screenPadding, 24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTokens.border)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 15, 6),
                    const SizedBox(height: 8),
                    _box(46, 11, 6),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: _box(70, 14, 6)),
              ),
              Expanded(
                flex: 3,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: _box(70, 14, 6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _box(double w, double h, double r) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
