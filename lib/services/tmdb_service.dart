import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/movie_detail.dart';

/// Kesalahan yang ditampilkan ke pengguna dengan pesan yang mudah dipahami.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Pilihan urutan pada halaman Rekomendasi.
enum SortOption {
  popular('Terpopuler', 'popularity.desc'),
  rating('Rating Tertinggi', 'vote_average.desc'),
  newest('Terbaru', 'primary_release_date.desc');

  final String label;
  final String apiValue;
  const SortOption(this.label, this.apiValue);
}

/// Semua komunikasi dengan TMDB REST API ada di kelas ini.
class TmdbService {
  TmdbService._();

  static final http.Client _client = http.Client();

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer ${ApiConfig.readAccessToken}',
        'Accept': 'application/json',
      };

  static String get _today {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  /// Mengirim permintaan GET, memeriksa status respons,
  /// lalu mengubah body JSON menjadi Map.
  static Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> query = const {},
  ]) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: {'language': ApiConfig.language, ...query},
    );

    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(
          'Server terlalu lama merespons. Coba lagi beberapa saat lagi.');
    } on SocketException {
      throw const ApiException(
          'Tidak ada koneksi internet. Periksa jaringanmu, lalu coba lagi.');
    } on http.ClientException {
      throw const ApiException(
          'Gagal terhubung ke server. Periksa koneksi internetmu.');
    }

    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          throw const ApiException('Data dari server tidak dapat diproses.');
        }
      case 401:
        throw const ApiException('Akses ditolak (401). API key tidak valid.');
      case 404:
        throw const ApiException('Data tidak ditemukan (404).');
      case 429:
        throw const ApiException(
            'Terlalu banyak permintaan (429). Tunggu sebentar, lalu coba lagi.');
      default:
        throw ApiException(
            'Server sedang bermasalah (kode ${response.statusCode}).');
    }
  }

  static Future<PagedMovies> _list(
    String path, {
    int page = 1,
    Map<String, String> query = const {},
  }) async {
    final json = await _get(path, {'page': '$page', ...query});
    return PagedMovies.fromJson(json);
  }

  // ---------------------------------------------------------------- Beranda

  static Future<PagedMovies> trending({int page = 1}) =>
      _list('/trending/movie/week', page: page);

  static Future<PagedMovies> nowPlaying({int page = 1}) => _list(
        '/movie/now_playing',
        page: page,
        query: {'region': ApiConfig.region},
      );

  /// Film yang akan tayang, diurutkan dari tanggal rilis terdekat.
  static Future<PagedMovies> upcoming({int page = 1}) async {
    final result = await _list(
      '/movie/upcoming',
      page: page,
      query: {'region': ApiConfig.region},
    );
    final today = _today;
    final future =
        result.movies.where((m) => m.releaseDate.compareTo(today) >= 0).toList();
    final movies = (future.isEmpty ? [...result.movies] : future)
      ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    return PagedMovies(
      movies: movies,
      page: result.page,
      totalPages: result.totalPages,
      totalResults: result.totalResults,
    );
  }

  static Future<PagedMovies> popular({int page = 1}) =>
      _list('/movie/popular', page: page, query: {'region': ApiConfig.region});

  static Future<PagedMovies> topRated({int page = 1}) =>
      _list('/movie/top_rated', page: page);

  // ------------------------------------------------------------ Rekomendasi

  /// Rekomendasi berdasarkan genre, urutan, dan rating minimum.
  /// Genre Animasi selalu dikecualikan.
  static Future<PagedMovies> discover({
    required List<int> genreIds,
    required SortOption sort,
    required double minRating,
    int page = 1,
  }) {
    return _list('/discover/movie', page: page, query: {
      'with_genres': genreIds.join(','),
      'without_genres': '${ApiConfig.animationGenreId}',
      'sort_by': sort.apiValue,
      'vote_average.gte': minRating.toStringAsFixed(1),
      'vote_count.gte': sort == SortOption.newest ? '20' : '150',
      'primary_release_date.lte': _today,
      'include_adult': 'false',
    });
  }

  // -------------------------------------------------------------- Pencarian

  static Future<PagedMovies> search(String query, {int page = 1}) => _list(
        '/search/movie',
        page: page,
        query: {'query': query, 'include_adult': 'false'},
      );

  // ----------------------------------------------------------------- Detail

  /// Detail film + pemeran + video + rekomendasi + penyedia streaming
  /// dalam satu permintaan (append_to_response).
  static Future<MovieDetail> detail(int id) async {
    final json = await _get('/movie/$id', {
      'append_to_response': 'credits,videos,recommendations,watch/providers',
      'include_video_language': 'id,en,null',
    });
    var detail = MovieDetail.fromJson(json);

    // Sinopsis Bahasa Indonesia kadang kosong, ganti dengan versi Inggris.
    if (detail.movie.overview.trim().isEmpty) {
      try {
        final en = await _get('/movie/$id', {'language': 'en-US'});
        final overview = (en['overview'] ?? '') as String;
        if (overview.isNotEmpty) detail = detail.withOverview(overview);
      } catch (_) {
        // Tidak fatal, sinopsis cukup ditampilkan kosong.
      }
    }

    // Jika rekomendasi kosong, pakai daftar film serupa.
    if (detail.recommendations.isEmpty) {
      try {
        final similar = await similarMovies(id);
        detail = detail.withRecommendations(similar.movies);
      } catch (_) {}
    }
    return detail;
  }

  static Future<PagedMovies> recommendations(int id, {int page = 1}) =>
      _list('/movie/$id/recommendations', page: page);

  static Future<PagedMovies> similarMovies(int id, {int page = 1}) =>
      _list('/movie/$id/similar', page: page);
}
