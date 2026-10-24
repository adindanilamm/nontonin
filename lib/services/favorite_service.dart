import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/movie.dart';

/// Menyimpan daftar film favorit di penyimpanan lokal HP (file JSON),
/// sehingga data tetap ada walaupun aplikasi ditutup.
///
/// Memakai ChangeNotifier agar semua halaman yang menampilkan status
/// favorit (ikon hati) langsung ikut berubah.
class FavoriteService extends ChangeNotifier {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final List<Movie> _items = [];
  bool _loaded = false;
  Future<List<Movie>>? _loading;

  List<Movie> get items => List.unmodifiable(_items);

  bool isFavorite(int id) => _items.any((m) => m.id == id);

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/nontonin_favorites.json');
  }

  /// Membaca favorit dari file. Hanya dibaca sekali, selanjutnya dari memori.
  Future<List<Movie>> load() {
    if (_loaded) return Future.value(items);
    return _loading ??= _read();
  }

  Future<List<Movie>> _read() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(list.map((e) => Movie.fromJson(e as Map<String, dynamic>)));
      }
      _loaded = true;
      notifyListeners();
      return items;
    } catch (e) {
      _loading = null;
      throw Exception('Gagal membaca data favorit.');
    }
  }

  Future<void> _save() async {
    final file = await _file();
    await file.writeAsString(jsonEncode(_items.map((m) => m.toJson()).toList()));
  }

  Future<void> add(Movie movie) async {
    if (isFavorite(movie.id)) return;
    _items.insert(0, movie);
    notifyListeners();
    await _save();
  }

  Future<void> remove(int id) async {
    _items.removeWhere((m) => m.id == id);
    notifyListeners();
    await _save();
  }

  /// Menambah atau menghapus. Mengembalikan true jika sekarang tersimpan.
  Future<bool> toggle(Movie movie) async {
    if (isFavorite(movie.id)) {
      await remove(movie.id);
      return false;
    }
    await add(movie);
    return true;
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _save();
  }

  /// Mengembalikan daftar sebelumnya (fitur "URUNGKAN").
  Future<void> restore(List<Movie> previous) async {
    _items
      ..clear()
      ..addAll(previous);
    notifyListeners();
    await _save();
  }
}
