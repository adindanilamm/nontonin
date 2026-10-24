/// Konfigurasi koneksi ke TMDB (The Movie Database).
///
/// Dokumentasi: https://developer.themoviedb.org/docs
class ApiConfig {
  ApiConfig._();

  /// Alamat dasar REST API TMDB versi 3.
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Alamat dasar gambar (poster, backdrop, foto pemeran, logo penyedia).
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// API Read Access Token, dikirim lewat header Authorization: Bearer.
  static const String readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5OThjMmZjZmZjNmFjNGQ4MmFjODJlMzIwN2ExM2Q5ZSIsIm5iZiI6MTc5MjY3NzIzNi4yMDg5OTk5LCJzdWIiOiI2YWRhMTU3NDk1NzE1OTE1NjAwMWY2YjEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.iTjzN8lMHsKDZLUplHTghhBkXgiEVtd9sQkY9irvdk0';

  /// API Key (v3). Disimpan sebagai cadangan, aplikasi memakai token di atas.
  static const String apiKey = '998c2fcffc6ac4d82ac82e3207a13d9e';

  /// Bahasa data (judul dan sinopsis) yang diminta ke TMDB.
  static const String language = 'id-ID';

  /// Wilayah untuk film sedang tayang, segera tayang, dan penyedia streaming.
  static const String region = 'ID';

  /// ID genre Animasi di TMDB. Film dengan genre ini tidak ditampilkan.
  static const int animationGenreId = 16;

  /// Batas waktu tiap permintaan HTTP.
  static const Duration timeout = Duration(seconds: 15);
}
