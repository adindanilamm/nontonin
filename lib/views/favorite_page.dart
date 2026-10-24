import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/movie.dart';
import '../services/favorite_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/movie_list_tile.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Halaman Favorit: daftar film yang disimpan pengguna di HP.
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final _service = FavoriteService.instance;
  late Future<List<Movie>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.load();
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 30),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(confirmLabel,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _remove(Movie movie) async {
    final ok = await _confirm(
      title: 'Hapus dari Favorit?',
      message: 'Film ini akan dihapus dari daftar favoritmu.',
      confirmLabel: 'Hapus',
    );
    if (ok != true) return;
    final before = List<Movie>.from(_service.items);
    await _service.remove(movie.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Dihapus dari Favorit',
      actionLabel: 'URUNGKAN',
      onAction: () => _service.restore(before),
    );
  }

  Future<void> _removeAll() async {
    final ok = await _confirm(
      title: 'Hapus Semua Favorit?',
      message: 'Semua film tersimpan akan dihapus.',
      confirmLabel: 'Hapus Semua',
    );
    if (ok != true) return;
    final before = List<Movie>.from(_service.items);
    await _service.clear();
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Semua favorit dihapus',
      actionLabel: 'URUNGKAN',
      onAction: () => _service.restore(before),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: FutureBuilder<List<Movie>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(4, (_) => const SkeletonListTile()),
            );
          }
          if (snapshot.hasError) {
            return StateView(
              icon: Icons.error_outline_rounded,
              iconColor: AppColors.error,
              title: 'Gagal Memuat Favorit',
              message: '${snapshot.error}'.replaceFirst('Exception: ', ''),
              buttonLabel: 'Coba Lagi',
              buttonIcon: Icons.refresh_rounded,
              onPressed: () => setState(() => _future = _service.load()),
            );
          }
          return ListenableBuilder(
            listenable: _service,
            builder: (context, _) {
              final items = _service.items;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Favorit Saya',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800)),
                              Text('${items.length} film tersimpan',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (items.isNotEmpty)
                          TextButton(
                            onPressed: _removeAll,
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary),
                            child: const Text('Hapus Semua',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? StateView(
                            icon: Icons.favorite_border_rounded,
                            title: 'Belum Ada Favorit',
                            message:
                                'Simpan film yang kamu suka dengan menekan ikon hati.',
                            buttonLabel: 'Jelajahi Film',
                            buttonIcon: Icons.explore_rounded,
                            onPressed: () => AppNav.goToTab(context, 0),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final m = items[i];
                              return MovieListTile(
                                movie: m,
                                onTap: () => AppNav.openDetail(context, m),
                                trailing: Material(
                                  color: Colors.black,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    tooltip: 'Hapus dari favorit',
                                    icon: const Icon(Icons.favorite_rounded,
                                        color: AppColors.primary),
                                    onPressed: () => _remove(m),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
