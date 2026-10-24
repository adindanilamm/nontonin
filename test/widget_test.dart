// Pengujian unit untuk proses konversi JSON TMDB menjadi objek Dart.
//
// Jalankan dengan perintah: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:nontonin/core/formatters.dart';
import 'package:nontonin/core/genres.dart';
import 'package:nontonin/models/movie.dart';
import 'package:nontonin/models/movie_detail.dart';

void main() {
  group('Movie.fromJson', () {
    test('membaca atribut utama film', () {
      final movie = Movie.fromJson({
        'id': 27205,
        'title': 'Inception',
        'original_title': 'Inception',
        'overview': 'Seorang pencuri...',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '2010-07-15',
        'vote_average': 8.369,
        'vote_count': 36000,
        'genre_ids': [28, 878, 12],
      });

      expect(movie.id, 27205);
      expect(movie.title, 'Inception');
      expect(movie.year, '2010');
      expect(movie.isAnimation, isFalse);
      expect(movie.posterUrl(), 'https://image.tmdb.org/t/p/w342/poster.jpg');
      expect(Genres.joinNames(movie.genreIds), 'Aksi, Fiksi Ilmiah');
    });

    test('tetap aman jika data kosong (null)', () {
      final movie = Movie.fromJson({'id': 1});
      expect(movie.title, '-');
      expect(movie.year, '-');
      expect(movie.voteAverage, 0);
      expect(movie.posterUrl(), isNull);
    });
  });

  test('PagedMovies menyaring film animasi', () {
    final paged = PagedMovies.fromJson({
      'page': 1,
      'total_pages': 3,
      'total_results': 60,
      'results': [
        {'id': 1, 'title': 'Film Biasa', 'genre_ids': [28]},
        {'id': 2, 'title': 'Film Animasi', 'genre_ids': [16, 35]},
      ],
    });
    expect(paged.movies.length, 1);
    expect(paged.movies.first.title, 'Film Biasa');
    expect(paged.hasMore, isTrue);
  });

  test('Trailer dipilih dari video YouTube bertipe Trailer resmi', () {
    final detail = MovieDetail.fromJson({
      'id': 10,
      'title': 'Contoh',
      'genres': [
        {'id': 28, 'name': 'Aksi'}
      ],
      'runtime': 135,
      'videos': {
        'results': [
          {'key': 'clip1', 'site': 'YouTube', 'type': 'Clip', 'official': true},
          {'key': 'teaser', 'site': 'YouTube', 'type': 'Teaser', 'official': true},
          {'key': 'trailer', 'site': 'YouTube', 'type': 'Trailer', 'official': true},
          {'key': 'vimeo', 'site': 'Vimeo', 'type': 'Trailer', 'official': true},
        ]
      },
    });
    expect(detail.trailer?.key, 'trailer');
    expect(detail.movie.genreIds, [28]);
  });

  test('Format durasi dan angka', () {
    expect(Fmt.runtime(135), '2j 15m');
    expect(Fmt.runtime(45), '45m');
    expect(Fmt.count(12400), '12,4 rb');
    expect(Fmt.rating(8.369), '8.4');
  });
}
