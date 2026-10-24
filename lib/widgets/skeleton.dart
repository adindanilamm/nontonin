import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Kotak abu-abu berkedip sebagai penanda data sedang dimuat (loading).
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Kerangka sebuah kartu poster.
class SkeletonPoster extends StatelessWidget {
  const SkeletonPoster({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 120, height: 180),
          SizedBox(height: 10),
          SkeletonBox(width: 100, height: 12, radius: 6),
          SizedBox(height: 6),
          SkeletonBox(width: 50, height: 10, radius: 6),
        ],
      ),
    );
  }
}

/// Kerangka sebuah baris daftar film.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 70, height: 105, radius: 10),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14, radius: 6),
                SizedBox(height: 10),
                SkeletonBox(width: 100, height: 10, radius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 120, height: 10, radius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 40, height: 10, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kerangka satu bagian horizontal (judul + deretan poster).
class SkeletonSection extends StatelessWidget {
  const SkeletonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonBox(width: 150, height: 20, radius: 6),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SkeletonPoster(),
            ),
          ),
        ],
      ),
    );
  }
}
