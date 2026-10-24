import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Halaman Cari: mencari film berdasarkan judul.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  Future<PagedMovies>? _future;

  static const _popular = [
    'Avengers',
    'Interstellar',
    'Dune',
    'John Wick',
    'Pengabdi Setan',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Pencarian dijalankan 500 ms setelah pengguna berhenti mengetik,
  /// supaya tidak mengirim permintaan di setiap huruf.
  void _onChanged(String text) {
    setState(() {}); // memperbarui tombol hapus (X)
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _run(text));
  }

  void _run(String text) {
    final q = text.trim();
    if (q == _query && _future != null) return;
    setState(() {
      _query = q;
      _future = q.isEmpty ? null : TmdbService.search(q);
    });
  }

  void _usePopular(String title) {
    _controller.text = title;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _debounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    _run(title);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _future = null;
    });
    AppNav.searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              focusNode: AppNav.searchFocus,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (t) {
                _debounce?.cancel();
                _run(t);
              },
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Cari judul film...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textPrimary),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _clear,
                      ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF2E2E38)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_future == null) return _initial();

    return FutureBuilder<PagedMovies>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(5, (_) => const SkeletonListTile()),
          );
        }
        if (snapshot.hasError) {
          return StateView.error(
            message: '${snapshot.error}',
            onRetry: () => setState(() => _future = TmdbService.search(_query)),
          );
        }
        final movies = snapshot.data!.movies;
        if (movies.isEmpty) {
          return const StateView(
            icon: Icons.search_off_rounded,
            title: 'Film Tidak Ditemukan',
            message: 'Coba gunakan kata kunci lain.',
          );
        }
        return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: movies.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(text: '${movies.length} hasil untuk '),
                      TextSpan(
                        text: '"$_query"',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            }
            final m = movies[i - 1];
            return MovieListTile(
              movie: m,
              onTap: () => AppNav.openDetail(context, m),
            );
          },
        );
      },
    );
  }

  Widget _initial() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text('Pencarian Populer',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popular
              .map((t) => ActionChip(
                    label: Text(t),
                    onPressed: () => _usePopular(t),
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    labelStyle: const TextStyle(fontSize: 13),
                  ))
              .toList(),
        ),
        const SizedBox(height: 120),
        const Icon(Icons.search_rounded, size: 56, color: AppColors.muted),
        const SizedBox(height: 12),
        const Text('Cari film berdasarkan judul',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
