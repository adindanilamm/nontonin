import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../models/movie.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Daftar lengkap sebuah kategori film dengan tombol "Muat Lebih Banyak".
class SeeAllPage extends StatefulWidget {
  final String title;
  final Future<PagedMovies> Function(int page) fetcher;
  final bool showReleaseDate;

  const SeeAllPage({
    super.key,
    required this.title,
    required this.fetcher,
    this.showReleaseDate = false,
  });

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  late Future<PagedMovies> _firstPage;
  final List<Movie> _movies = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _firstPage = _loadFirst();
  }

  Future<PagedMovies> _loadFirst() async {
    final result = await widget.fetcher(1);
    _movies
      ..clear()
      ..addAll(result.movies);
    _page = 1;
    _hasMore = result.hasMore;
    return result;
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await widget.fetcher(_page + 1);
      final ids = _movies.map((m) => m.id).toSet();
      setState(() {
        _movies.addAll(result.movies.where((m) => !ids.contains(m.id)));
        _page = result.page;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '$e', type: SnackType.error);
      }
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
        title: Text(widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<PagedMovies>(
        future: _firstPage,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (_) => const SkeletonListTile()),
            );
          }
          if (snapshot.hasError) {
            return StateView.error(
              message: '${snapshot.error}',
              onRetry: () => setState(() => _firstPage = _loadFirst()),
            );
          }
          if (_movies.isEmpty) {
            return const StateView(
              icon: Icons.movie_filter_outlined,
              title: 'Belum Ada Film',
              message: 'Daftar film untuk kategori ini masih kosong.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _movies.length + 1,
            itemBuilder: (context, i) {
              if (i < _movies.length) {
                final m = _movies[i];
                return MovieListTile(
                  movie: m,
                  onTap: () => AppNav.openDetail(context, m),
                  trailing: widget.showReleaseDate
                      ? Text(Fmt.date(m.releaseDate),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.primary))
                      : null,
                );
              }
              if (!_hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Semua film sudah ditampilkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                );
              }
              if (_loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Memuat...'),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SecondaryButton(
                  label: 'Muat Lebih Banyak',
                  onPressed: _loadMore,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
