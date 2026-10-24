import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'detail_page.dart';
import 'see_all_page.dart';

/// Pengendali navigasi antarhalaman yang dipakai bersama.
class AppNav {
  AppNav._();

  /// Indeks tab yang aktif di bottom navigation.
  /// 0 = Beranda, 1 = Rekomendasi, 2 = Cari, 3 = Favorit.
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  /// Fokus kolom pencarian (dipakai saat ikon cari di Beranda ditekan).
  static final FocusNode searchFocus = FocusNode();

  static void goToTab(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    tab.value = index;
    if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchFocus.requestFocus();
      });
    }
  }

  static Future<void> openDetail(BuildContext context, Movie movie) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailPage(movie: movie)),
    );
  }

  static Future<void> openSeeAll(
    BuildContext context, {
    required String title,
    required Future<PagedMovies> Function(int page) fetcher,
    bool showReleaseDate = false,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeeAllPage(
          title: title,
          fetcher: fetcher,
          showReleaseDate: showReleaseDate,
        ),
      ),
    );
  }
}
