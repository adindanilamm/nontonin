import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../core/genres.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/net_image.dart';
import '../widgets/poster_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Kumpulan data yang dibutuhkan halaman Beranda.
class HomeData {
  final List<Movie> trending;
  final List<Movie> nowPlaying;
  final List<Movie> upcoming;
  final List<Movie> popular;
  final List<Movie> topRated;

  const HomeData({
    required this.trending,
    required this.nowPlaying,
    required this.upcoming,
    required this.popular,
    required this.topRated,
  });
}

/// Halaman Beranda: trending, sedang tayang, segera tayang,
/// populer, dan rating tertinggi.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Lima permintaan API dijalankan bersamaan dengan Future.wait,
  /// sehingga waktu tunggu lebih singkat.
  Future<HomeData> _load() async {
    final results = await Future.wait([
      TmdbService.trending(),
      TmdbService.nowPlaying(),
      TmdbService.upcoming(),
      TmdbService.popular(),
      TmdbService.topRated(),
    ]);
    return HomeData(
      trending: results[0].movies.take(6).toList(),
      nowPlaying: results[1].movies,
      upcoming: results[2].movies,
      popular: results[3].movies,
      topRated: results[4].movies,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // Error sudah ditangani oleh FutureBuilder.
    }
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: FutureBuilder<HomeData>(
        future: _future,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState != ConnectionState.done) {
            return const _HomeLoading();
          }
          // 2. Error
          if (snapshot.hasError) {
            return Column(
              children: [
                const _HomeHeader(),
                Expanded(
                  child: StateView.error(
                    message: '${snapshot.error}',
                    onRetry: _retry,
                  ),
                ),
              ],
            );
          }
          // 3. Sukses
          final data = snapshot.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const _HomeHeader(),
                if (data.trending.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text('Trending Minggu Ini',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  _TrendingCarousel(movies: data.trending),
                  const SizedBox(height: 24),
                ],
                _section(
                  context,
                  title: 'Sedang Tayang',
                  movies: data.nowPlaying,
                  fetcher: (p) => TmdbService.nowPlaying(page: p),
                ),
                _section(
                  context,
                  title: 'Segera Tayang',
                  movies: data.upcoming,
                  fetcher: (p) => TmdbService.upcoming(page: p),
                  showReleaseBadge: true,
                ),
                _section(
                  context,
                  title: 'Populer',
                  movies: data.popular,
                  fetcher: (p) => TmdbService.popular(page: p),
                ),
                _section(
                  context,
                  title: 'Rating Tertinggi',
                  movies: data.topRated,
                  fetcher: (p) => TmdbService.topRated(page: p),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Data film disediakan oleh TMDB',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Movie> movies,
    required Future<PagedMovies> Function(int page) fetcher,
    bool showReleaseBadge = false,
  }) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            onSeeAll: () => AppNav.openSeeAll(
              context,
              title: title,
              fetcher: fetcher,
              showReleaseDate: showReleaseBadge,
            ),
          ),
          PosterRow(
            movies: movies,
            showReleaseBadge: showReleaseBadge,
            onTap: (m) => AppNav.openDetail(context, m),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, Selamat Datang 👋',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                SizedBox(height: 2),
                Text('Mau nonton apa hari ini?',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Material(
            color: Colors.black,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Cari film',
              icon: const Icon(Icons.search_rounded, color: Colors.white),
              onPressed: () => AppNav.goToTab(context, 2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner film trending yang bisa digeser dan berganti otomatis.
class _TrendingCarousel extends StatefulWidget {
  final List<Movie> movies;

  const _TrendingCarousel({required this.movies});

  @override
  State<_TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<_TrendingCarousel> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients || widget.movies.isEmpty) return;
      final next = (_index + 1) % widget.movies.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.movies.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final m = widget.movies[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => AppNav.openDetail(context, m),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetImage(url: m.backdropUrl()),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xE60F0F14)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${m.year} • ${Genres.joinNames(m.genreIds)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.gold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(Fmt.rating(m.voteAverage),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const Text(' /10',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white60)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 38,
                                child: PrimaryButton(
                                  label: 'Lihat Detail',
                                  icon: Icons.play_arrow_rounded,
                                  onPressed: () =>
                                      AppNav.openDetail(context, m),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.muted,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _HomeHeader(),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text('Trending Minggu Ini',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonBox(height: 200, radius: 16),
        ),
        SizedBox(height: 28),
        SkeletonSection(),
        SkeletonSection(),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Memuat film...',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}
