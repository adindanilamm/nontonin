import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/genres.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/poster_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Hasil rekomendasi berupa grid 2 kolom.
class RecommendationResultPage extends StatefulWidget {
  final List<int> genreIds;
  final SortOption sort;
  final double minRating;

  const RecommendationResultPage({
    super.key,
    required this.genreIds,
    required this.sort,
    required this.minRating,
  });

  @override
  State<RecommendationResultPage> createState() =>
      _RecommendationResultPageState();
}

class _RecommendationResultPageState extends State<RecommendationResultPage> {
  late Future<PagedMovies> _firstPage;
  final List<Movie> _movies = [];
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _firstPage = _load(1);
  }

  Future<PagedMovies> _fetch(int page) => TmdbService.discover(
        genreIds: widget.genreIds,
        sort: widget.sort,
        minRating: widget.minRating,
        page: page,
      );

  Future<PagedMovies> _load(int page) async {
    final result = await _fetch(page);
    _movies
      ..clear()
      ..addAll(result.movies);
    _page = result.page;
    _total = result.totalResults;
    _hasMore = result.hasMore;
    return result;
  }

  Future<void> _reload() async {
    final future = _load(1);
    setState(() {
      _firstPage = future;
    });
    try {
      await future;
    } catch (_) {}
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await _fetch(_page + 1);
      final ids = _movies.map((m) => m.id).toSet();
      setState(() {
        _movies.addAll(result.movies.where((m) => !ids.contains(m.id)));
        _page = result.page;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (mounted) showAppSnackBar(context, '$e', type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Hasil Rekomendasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Ubah Filter'),
          ),
        ],
      ),
      body: FutureBuilder<PagedMovies>(
        future: _firstPage,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _loadingGrid();
          }
          if (snapshot.hasError) {
            return RefreshableState(
              onRefresh: _reload,
              child: StateView.error(
                message: '${snapshot.error}',
                onRetry: _reload,
              ),
            );
          }
          if (_movies.isEmpty) {
            return StateView(
              icon: Icons.movie_filter_outlined,
              title: 'Tidak Ada Film yang Cocok',
              message: 'Coba kurangi genre atau turunkan rating minimum.',
              buttonLabel: 'Ubah Filter',
              primaryButton: false,
              onPressed: () => Navigator.of(context).pop(),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _summary()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.52,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final m = _movies[i];
                      return PosterCard(
                        movie: m,
                        width: double.infinity,
                        onTap: () => AppNav.openDetail(context, m),
                      );
                    },
                    childCount: _movies.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: !_hasMore
                      ? const Text('Semua rekomendasi sudah ditampilkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary))
                      : _loadingMore
                          ? const Center(
                              child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            )
                          : SecondaryButton(
                              label: 'Muat Lebih Banyak',
                              onPressed: _loadMore,
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summary() {
    final chips = [
      ...widget.genreIds.map(Genres.nameOf),
      'Rating ${widget.minRating.toStringAsFixed(1)}+',
      widget.sort.label,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text('Menampilkan ${_movies.length} dari $_total film',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _loadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.52,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 2 / 3, child: SkeletonBox(height: 0)),
          SizedBox(height: 10),
          SkeletonBox(width: 120, height: 12, radius: 6),
          SizedBox(height: 6),
          SkeletonBox(width: 50, height: 10, radius: 6),
        ],
      ),
    );
  }
}
