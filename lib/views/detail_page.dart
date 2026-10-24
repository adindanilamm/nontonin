import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../services/favorite_service.dart';
import '../services/link_launcher.dart';
import '../services/tmdb_service.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/net_image.dart';
import '../widgets/poster_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton.dart';
import '../widgets/state_view.dart';
import 'app_nav.dart';

/// Halaman detail film: info lengkap, trailer, tempat menonton,
/// sinopsis, pemeran, dan film serupa.
class DetailPage extends StatefulWidget {
  final Movie movie;

  const DetailPage({super.key, required this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<MovieDetail> _future;
  bool _synopsisExpanded = false;
  final _favorites = FavoriteService.instance;

  @override
  void initState() {
    super.initState();
    _future = TmdbService.detail(widget.movie.id);
    _favorites.load().catchError((_) => <Movie>[]);
  }

  // ------------------------------------------------------------- Aksi

  Future<void> _toggleFavorite(MovieDetail? detail) async {
    final base = detail?.movie ?? widget.movie;
    final movie = Movie(
      id: base.id,
      title: base.title,
      originalTitle: base.originalTitle,
      overview: base.overview,
      posterPath: base.posterPath,
      backdropPath: base.backdropPath,
      releaseDate: base.releaseDate,
      voteAverage: base.voteAverage,
      voteCount: base.voteCount,
      genreIds: base.genreIds,
      runtime: detail?.runtime ?? base.runtime,
    );
    final saved = await _favorites.toggle(movie);
    if (!mounted) return;
    if (saved) {
      showAppSnackBar(
        context,
        'Ditambahkan ke Favorit',
        actionLabel: 'LIHAT',
        onAction: () => AppNav.goToTab(context, 3),
      );
    } else {
      showAppSnackBar(
        context,
        'Dihapus dari Favorit',
        type: SnackType.neutral,
        actionLabel: 'URUNGKAN',
        onAction: () => _favorites.add(movie),
      );
    }
  }

  /// Menampilkan lembar "Membuka trailer di YouTube...", lalu membuka
  /// aplikasi YouTube dengan video trailer milik film ini.
  Future<void> _playTrailer(VideoItem trailer) async {
    var cancelled = false;
    final sheet = showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_display_rounded,
                color: AppColors.youtube, size: 52),
            const SizedBox(height: 12),
            const Text('Membuka trailer di YouTube...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              trailer.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                cancelled = true;
                Navigator.of(sheetContext).pop();
              },
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );

    var sheetOpen = true;
    sheet.whenComplete(() => sheetOpen = false);
    await Future.delayed(const Duration(milliseconds: 1000));
    // Jika lembar ditutup (Batal / digeser ke bawah), trailer tidak dibuka.
    if (!mounted || cancelled || !sheetOpen) return;
    Navigator.of(context).pop();

    final ok = await LinkLauncher.openYoutube(trailer.key);
    if (!ok && mounted) {
      showAppSnackBar(context, 'Tidak dapat membuka YouTube.',
          type: SnackType.error);
    }
  }

  /// Konfirmasi sebelum diarahkan ke halaman tempat menonton.
  Future<void> _openProvider(String link, WatchProvider? provider) async {
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider != null)
              NetImage(
                url: provider.logoUrl,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(14),
                placeholderIcon: Icons.live_tv_rounded,
              )
            else
              const Icon(Icons.live_tv_rounded,
                  size: 52, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              provider == null ? 'Semua opsi tonton' : provider.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kamu akan diarahkan ke halaman tempat menonton film ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Lanjutkan',
                icon: Icons.open_in_new_rounded,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
    if (go != true) return;
    final ok = await LinkLauncher.openUrl(link);
    if (!ok && mounted) {
      showAppSnackBar(context, 'Tidak dapat membuka halaman.',
          type: SnackType.error);
    }
  }

  void _share(Movie movie) {
    final url = 'https://www.themoviedb.org/movie/${movie.id}';
    final text = 'Yuk nonton "${movie.title}" (${movie.year})! $url';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        Widget option(IconData icon, Color color, String label,
            Future<void> Function() action) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await action();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bagikan film',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  option(Icons.chat_rounded, AppColors.success, 'WhatsApp',
                      () async {
                    final ok = await LinkLauncher.openUrl(
                        'https://wa.me/?text=${Uri.encodeComponent(text)}');
                    if (!ok && mounted) {
                      showAppSnackBar(context, 'WhatsApp tidak dapat dibuka.',
                          type: SnackType.error);
                    }
                  }),
                  option(Icons.link_rounded, AppColors.gold, 'Salin Tautan',
                      () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (mounted) showAppSnackBar(context, 'Tautan disalin');
                  }),
                  option(Icons.public_rounded, const Color(0xFF01B4E4),
                      'Buka di TMDB', () async {
                    await LinkLauncher.openUrl(url);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------- Tampilan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _loading();
          }
          if (snapshot.hasError) {
            return Stack(
              children: [
                StateView.error(
                  message: '${snapshot.error}',
                  onRetry: () => setState(() =>
                      _future = TmdbService.detail(widget.movie.id)),
                ),
                _topButtons(null),
              ],
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _topButtons(MovieDetail? detail) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleIconButton(
              tooltip: 'Kembali',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            if (detail != null) ...[
              ListenableBuilder(
                listenable: _favorites,
                builder: (context, _) {
                  final fav = _favorites.isFavorite(detail.movie.id);
                  return CircleIconButton(
                    tooltip: fav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                    icon: fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: fav ? AppColors.primary : Colors.white,
                    onPressed: () => _toggleFavorite(detail),
                  );
                },
              ),
              const SizedBox(width: 10),
              CircleIconButton(
                tooltip: 'Bagikan',
                icon: Icons.share_rounded,
                onPressed: () => _share(detail.movie),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _content(MovieDetail d) {
    final m = d.movie;
    final trailer = d.trailer;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(d),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (d.genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: d.genres
                          .map((g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(g.name,
                                    style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: trailer == null
                              ? 'Trailer Tidak Tersedia'
                              : 'Tonton Trailer',
                          icon: Icons.play_circle_outline_rounded,
                          onPressed: trailer == null
                              ? null
                              : () => _playTrailer(trailer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _favorites,
                          builder: (context, _) {
                            final fav = _favorites.isFavorite(m.id);
                            return SecondaryButton(
                              label: fav ? 'Tersimpan' : 'Favorit',
                              icon: fav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              borderColor:
                                  fav ? AppColors.primary : Colors.white,
                              foreground:
                                  fav ? AppColors.primary : Colors.white,
                              onPressed: () => _toggleFavorite(d),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _providers(d),
                  const SizedBox(height: 24),
                  _synopsis(m.overview, d.tagline),
                  const SizedBox(height: 20),
                  _infoGrid(d),
                ],
              ),
            ),
            if (d.cast.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Pemeran',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              _castRow(d.cast),
            ],
            if (d.recommendations.isNotEmpty) ...[
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Film Serupa',
                onSeeAll: () => AppNav.openSeeAll(
                  context,
                  title: 'Mirip ${m.title}',
                  fetcher: (p) => TmdbService.recommendations(m.id, page: p),
                ),
              ),
              PosterRow(
                movies: d.recommendations,
                onTap: (movie) => AppNav.openDetail(context, movie),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
        _topButtons(d),
      ],
    );
  }

  Widget _header(MovieDetail d) {
    final m = d.movie;
    final meta = [
      m.year,
      if (d.runtime != null && d.runtime! > 0) Fmt.runtime(d.runtime),
      Fmt.language(d.originalLanguage),
    ].join(' • ');

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: NetImage(url: m.backdropUrl('w1280')),
          ),
          const SizedBox(
            height: 262,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x660F0F14),
                    Color(0x000F0F14),
                    AppColors.background,
                  ],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 16),
                    ],
                  ),
                  child: NetImage(
                    url: m.posterUrl(),
                    width: 110,
                    height: 165,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2),
                      ),
                      if (m.originalTitle.isNotEmpty &&
                          m.originalTitle != m.title)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            m.originalTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(meta,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            m.voteAverage > 0 ? Fmt.rating(m.voteAverage) : '-',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const Text(' /10',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('(${Fmt.count(m.voteCount)} ulasan)',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _providers(MovieDetail d) {
    final p = d.providers;

    Widget group(String label, List<WatchProvider> list, String link) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final provider = list[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openProvider(link, provider),
                    child: SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          NetImage(
                            url: provider.logoUrl,
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(12),
                            placeholderIcon: Icons.live_tv_rounded,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text('Tersedia di',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            Text('Sumber: JustWatch',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        if (p == null || p.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.tv_off_rounded, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Belum tersedia di layanan streaming Indonesia.',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          group('Streaming', p.streaming, p.link),
          group('Sewa', p.rent, p.link),
          group('Beli', p.buy, p.link),
          if (p.link.isNotEmpty)
            Center(
              child: TextButton(
                onPressed: () => _openProvider(p.link, null),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat semua opsi tonton'),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _synopsis(String overview, String tagline) {
    final text = overview.trim().isEmpty
        ? 'Sinopsis belum tersedia untuk film ini.'
        : overview.trim();
    final long = text.length > 220;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sinopsis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        if (tagline.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('"$tagline"',
              style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: Text(
            text,
            maxLines: _synopsisExpanded || !long ? null : 4,
            overflow: _synopsisExpanded || !long
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
        if (long)
          Center(
            child: TextButton(
              onPressed: () =>
                  setState(() => _synopsisExpanded = !_synopsisExpanded),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text(_synopsisExpanded ? 'Sembunyikan' : 'Selengkapnya'),
            ),
          ),
      ],
    );
  }

  Widget _infoGrid(MovieDetail d) {
    final items = [
      ('Tanggal Rilis', Fmt.date(d.movie.releaseDate)),
      ('Durasi', d.runtime == null || d.runtime == 0 ? '-' : '${d.runtime} menit'),
      ('Bahasa', Fmt.language(d.originalLanguage)),
      ('Status', Fmt.status(d.status)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: items
          .map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.$1,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(e.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _castRow(List<CastMember> cast) {
    final list = cast.take(15).toList();
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final c = list[i];
          return SizedBox(
            width: 76,
            child: Column(
              children: [
                NetImage(
                  url: c.photoUrl,
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(32),
                  placeholderIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 8),
                Text(c.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text(c.character,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _loading() {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonBox(height: 260, radius: 0),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: 110, height: 165),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 20, radius: 6),
                        SizedBox(height: 10),
                        SkeletonBox(width: 120, height: 12, radius: 6),
                        SizedBox(height: 10),
                        SkeletonBox(width: 80, height: 14, radius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonBox(height: 52),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 120, height: 18, radius: 6),
                  SizedBox(height: 12),
                  SkeletonBox(height: 12, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(height: 12, radius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 200, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
        _topButtons(null),
      ],
    );
  }
}
