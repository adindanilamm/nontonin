/// Daftar genre film TMDB beserta nama Bahasa Indonesia.
///
/// ID genre mengikuti endpoint /genre/movie/list milik TMDB.
class Genres {
  Genres._();

  static const Map<int, String> names = {
    28: 'Aksi',
    12: 'Petualangan',
    16: 'Animasi',
    35: 'Komedi',
    80: 'Kriminal',
    99: 'Dokumenter',
    18: 'Drama',
    10751: 'Keluarga',
    14: 'Fantasi',
    36: 'Sejarah',
    27: 'Horor',
    10402: 'Musik',
    9648: 'Misteri',
    10749: 'Romantis',
    878: 'Fiksi Ilmiah',
    10770: 'Film TV',
    53: 'Thriller',
    10752: 'Perang',
    37: 'Western',
  };

  /// Genre yang bisa dipilih di halaman Rekomendasi (tanpa Animasi).
  static const List<int> selectable = [
    28, 12, 35, 18, 27, 10749, 53, 878, 14, 9648, 80, 10751, 36, 10752,
  ];

  static String nameOf(int id) => names[id] ?? 'Lainnya';

  /// Mengubah daftar ID genre menjadi teks, misalnya "Aksi, Thriller".
  static String joinNames(List<int> ids, {int max = 2}) {
    final list = ids.where(names.containsKey).take(max).map(nameOf).toList();
    return list.isEmpty ? '-' : list.join(', ');
  }
}
