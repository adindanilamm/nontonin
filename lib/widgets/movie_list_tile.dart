import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../core/genres.dart';
import '../models/movie.dart';
import 'net_image.dart';

/// Baris film horizontal: poster di kiri, informasi di kanan.
class MovieListTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final Widget? trailing;

  const MovieListTile({
    super.key,
    required this.movie,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final meta = movie.runtime == null
        ? movie.year
        : '${movie.year} • ${Fmt.runtime(movie.runtime)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                NetImage(
                  url: movie.posterUrl('w185'),
                  width: 70,
                  height: 105,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(meta,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        Genres.joinNames(movie.genreIds),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage > 0
                                ? Fmt.rating(movie.voteAverage)
                                : 'Belum ada rating',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
