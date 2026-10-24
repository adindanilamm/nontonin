import '../config/api_config.dart';

/// Model ringkas sebuah film, dipakai di semua daftar film
/// (beranda, rekomendasi, pencarian, favorit, film serupa).
class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;

  /// Durasi dalam menit. Hanya tersedia dari endpoint detail,
  /// sehingga bisa bernilai null di daftar biasa.
  final int? runtime;

  const Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
    this.runtime,
  });

  /// Mengubah satu objek JSON dari TMDB menjadi objek Movie.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? '-') as String,
      originalTitle: (json['original_title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (json['release_date'] ?? '') as String,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      genreIds: ((json['genre_ids'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      runtime: (json['runtime'] as num?)?.toInt(),
    );
  }

  /// Kebalikan dari fromJson, dipakai untuk menyimpan film favorit.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'original_title': originalTitle,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'release_date': releaseDate,
        'vote_average': voteAverage,
        'vote_count': voteCount,
        'genre_ids': genreIds,
        'runtime': runtime,
      };

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '-';

  bool get isAnimation => genreIds.contains(ApiConfig.animationGenreId);

  String? posterUrl([String size = 'w342']) =>
      posterPath == null ? null : '${ApiConfig.imageBaseUrl}/$size$posterPath';

  String? backdropUrl([String size = 'w780']) => backdropPath == null
      ? posterUrl('w780')
      : '${ApiConfig.imageBaseUrl}/$size$backdropPath';
}

/// Hasil satu halaman daftar film dari TMDB (mendukung "Muat Lebih Banyak").
class PagedMovies {
  final List<Movie> movies;
  final int page;
  final int totalPages;
  final int totalResults;

  const PagedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  bool get hasMore => page < totalPages;

  /// Membaca respons berbentuk { page, results: [...], total_pages, total_results }.
  /// Film animasi disaring keluar di sini.
  factory PagedMovies.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? const [];
    final movies = results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .where((m) => !m.isAnimation)
        .toList();
    return PagedMovies(
      movies: movies,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalResults: (json['total_results'] as num?)?.toInt() ?? movies.length,
    );
  }
}
