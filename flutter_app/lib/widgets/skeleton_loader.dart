import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(curve: Curves.easeInOutSine, parent: _controller),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: const Alignment(1, 0),
              colors: [
                AppConstants.dividerColor.withOpacity(0.5),
                AppConstants.dividerColor,
                AppConstants.dividerColor.withOpacity(0.5),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        );
      },
    );
  }
}

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 150, height: 20, borderRadius: 4),
              SkeletonLoader(width: 80, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 16, borderRadius: 4),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(width: 100, height: 28, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
