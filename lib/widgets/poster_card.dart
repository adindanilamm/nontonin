import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../models/movie.dart';
import 'net_image.dart';

/// Kartu poster film vertikal (dipakai di deretan horizontal dan grid).
class PosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final bool showReleaseBadge;

  const PosterCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 120,
    this.showReleaseBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(
                    url: movie.posterUrl(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: RatingPill(value: movie.voteAverage),
                  ),
                  if (showReleaseBadge && movie.releaseDate.isNotEmpty)
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: DateBadge(text: Fmt.date(movie.releaseDate)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              movie.year,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label rating kecil: bintang emas + angka.
class RatingPill extends StatelessWidget {
  final double value;

  const RatingPill({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 3),
          Text(
            value > 0 ? Fmt.rating(value) : '-',
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Label tanggal berwarna merah (untuk film Segera Tayang).
class DateBadge extends StatelessWidget {
  final String text;

  const DateBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

/// Deretan poster yang bisa digeser ke samping.
class PosterRow extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie) onTap;
  final bool showReleaseBadge;

  const PosterRow({
    super.key,
    required this.movies,
    required this.onTap,
    this.showReleaseBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 264,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => PosterCard(
          movie: movies[i],
          showReleaseBadge: showReleaseBadge,
          onTap: () => onTap(movies[i]),
        ),
      ),
    );
  }
}
