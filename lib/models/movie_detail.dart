import '../config/api_config.dart';
import 'movie.dart';

/// Model detail lengkap sebuah film.
///
/// Diambil dari satu permintaan:
/// /movie/{id}?append_to_response=credits,videos,recommendations,watch/providers
class MovieDetail {
  final Movie movie;
  final String tagline;
  final List<Genre> genres;
  final int? runtime;
  final String status;
  final String originalLanguage;
  final List<CastMember> cast;
  final List<VideoItem> videos;
  final List<Movie> recommendations;
  final WatchProviders? providers;

  const MovieDetail({
    required this.movie,
    required this.tagline,
    required this.genres,
    required this.runtime,
    required this.status,
    required this.originalLanguage,
    required this.cast,
    required this.videos,
    required this.recommendations,
    required this.providers,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genres = ((json['genres'] as List?) ?? const [])
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        .toList();

    // Endpoint detail memakai "genres", bukan "genre_ids",
    // jadi id-nya dipindahkan agar model Movie tetap lengkap.
    final movieJson = Map<String, dynamic>.from(json)
      ..['genre_ids'] = genres.map((g) => g.id).toList();

    final cast = (((json['credits'] as Map?)?['cast'] as List?) ?? const [])
        .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
        .toList();

    final videos = (((json['videos'] as Map?)?['results'] as List?) ?? const [])
        .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final recommendations =
        (((json['recommendations'] as Map?)?['results'] as List?) ?? const [])
            .map((e) => Movie.fromJson(e as Map<String, dynamic>))
            .where((m) => !m.isAnimation)
            .toList();

    final providerResults =
        (json['watch/providers'] as Map?)?['results'] as Map?;
    final regional = providerResults?[ApiConfig.region] as Map?;

    return MovieDetail(
      movie: Movie.fromJson(movieJson),
      tagline: (json['tagline'] ?? '') as String,
      genres: genres,
      runtime: (json['runtime'] as num?)?.toInt(),
      status: (json['status'] ?? '') as String,
      originalLanguage: (json['original_language'] ?? '') as String,
      cast: cast,
      videos: videos,
      recommendations: recommendations,
      providers: regional == null
          ? null
          : WatchProviders.fromJson(Map<String, dynamic>.from(regional)),
    );
  }

  /// Memilih trailer YouTube yang paling tepat untuk film ini.
  ///
  /// Semua video berasal dari endpoint /movie/{id}/videos, jadi pasti
  /// milik film yang sama. Urutan prioritas: tipe Trailer, lalu Teaser,
  /// video resmi (official) didahulukan.
  VideoItem? get trailer {
    final candidates = videos
        .where((v) =>
            v.site == 'YouTube' &&
            v.key.isNotEmpty &&
            (v.type == 'Trailer' || v.type == 'Teaser'))
        .toList();
    if (candidates.isEmpty) return null;

    int score(VideoItem v) {
      var s = 0;
      if (v.type == 'Trailer') s += 4;
      if (v.official) s += 2;
      if (v.language == 'id') s += 1;
      return s;
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));
    return candidates.first;
  }

  /// Salinan detail dengan sinopsis pengganti (dipakai saat sinopsis
  /// Bahasa Indonesia kosong dan diganti versi Bahasa Inggris).
  MovieDetail withOverview(String overview) {
    final m = movie;
    return MovieDetail(
      movie: Movie(
        id: m.id,
        title: m.title,
        originalTitle: m.originalTitle,
        overview: overview,
        posterPath: m.posterPath,
        backdropPath: m.backdropPath,
        releaseDate: m.releaseDate,
        voteAverage: m.voteAverage,
        voteCount: m.voteCount,
        genreIds: m.genreIds,
        runtime: m.runtime,
      ),
      tagline: tagline,
      genres: genres,
      runtime: runtime,
      status: status,
      originalLanguage: originalLanguage,
      cast: cast,
      videos: videos,
      recommendations: recommendations,
      providers: providers,
    );
  }

  MovieDetail withRecommendations(List<Movie> list) => MovieDetail(
        movie: movie,
        tagline: tagline,
        genres: genres,
        runtime: runtime,
        status: status,
        originalLanguage: originalLanguage,
        cast: cast,
        videos: videos,
        recommendations: list,
        providers: providers,
      );
}

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '') as String,
      );
}

class CastMember {
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        name: (json['name'] ?? '-') as String,
        character: (json['character'] ?? '') as String,
        profilePath: json['profile_path'] as String?,
      );

  String? get photoUrl => profilePath == null
      ? null
      : '${ApiConfig.imageBaseUrl}/w185$profilePath';
}

class VideoItem {
  final String name;
  final String key;
  final String site;
  final String type;
  final bool official;
  final String language;

  const VideoItem({
    required this.name,
    required this.key,
    required this.site,
    required this.type,
    required this.official,
    required this.language,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
        name: (json['name'] ?? '') as String,
        key: (json['key'] ?? '') as String,
        site: (json['site'] ?? '') as String,
        type: (json['type'] ?? '') as String,
        official: (json['official'] ?? false) as bool,
        language: (json['iso_639_1'] ?? '') as String,
      );

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}

/// Daftar layanan tempat film bisa ditonton di Indonesia.
/// Sumber data: JustWatch (melalui TMDB).
class WatchProviders {
  final String link;
  final List<WatchProvider> streaming;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;

  const WatchProviders({
    required this.link,
    required this.streaming,
    required this.rent,
    required this.buy,
  });

  bool get isEmpty => streaming.isEmpty && rent.isEmpty && buy.isEmpty;

  factory WatchProviders.fromJson(Map<String, dynamic> json) {
    List<WatchProvider> read(String key) => ((json[key] as List?) ?? const [])
        .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return WatchProviders(
      link: (json['link'] ?? '') as String,
      streaming: read('flatrate'),
      rent: read('rent'),
      buy: read('buy'),
    );
  }
}

class WatchProvider {
  final int id;
  final String name;
  final String? logoPath;
  final int priority;

  const WatchProvider({
    required this.id,
    required this.name,
    required this.logoPath,
    required this.priority,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) => WatchProvider(
        id: (json['provider_id'] as num?)?.toInt() ?? 0,
        name: (json['provider_name'] ?? '-') as String,
        logoPath: json['logo_path'] as String?,
        priority: (json['display_priority'] as num?)?.toInt() ?? 999,
      );

  String? get logoUrl =>
      logoPath == null ? null : '${ApiConfig.imageBaseUrl}/w154$logoPath';
}
