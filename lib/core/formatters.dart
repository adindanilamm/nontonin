import 'package:intl/intl.dart';

/// Kumpulan fungsi bantu untuk memformat data agar mudah dibaca.
class Fmt {
  Fmt._();

  /// "2025-03-12" -> "12 Mar 2025".
  static String date(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
  }

  /// 135 -> "2j 15m".
  static String runtime(int? minutes) {
    if (minutes == null || minutes <= 0) return '-';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}j' : '${h}j ${m}m';
  }

  /// 8.4321 -> "8.4".
  static String rating(double value) => value.toStringAsFixed(1);

  /// 12400 -> "12,4 rb".
  static String count(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} jt';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1).replaceAll('.', ',')} rb';
    }
    return '$value';
  }

  static const Map<String, String> _languages = {
    'en': 'Inggris',
    'id': 'Indonesia',
    'ko': 'Korea',
    'ja': 'Jepang',
    'zh': 'Mandarin',
    'cn': 'Kanton',
    'fr': 'Prancis',
    'es': 'Spanyol',
    'hi': 'Hindi',
    'th': 'Thailand',
    'de': 'Jerman',
    'it': 'Italia',
    'ru': 'Rusia',
    'pt': 'Portugis',
    'tr': 'Turki',
    'ms': 'Melayu',
    'tl': 'Tagalog',
    'ta': 'Tamil',
    'te': 'Telugu',
  };

  static String language(String code) =>
      _languages[code] ?? (code.isEmpty ? '-' : code.toUpperCase());

  static String status(String raw) {
    switch (raw) {
      case 'Released':
        return 'Rilis';
      case 'Post Production':
        return 'Pascaproduksi';
      case 'In Production':
        return 'Produksi';
      case 'Planned':
        return 'Direncanakan';
      case 'Rumored':
        return 'Rumor';
      case 'Canceled':
        return 'Dibatalkan';
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }
}
