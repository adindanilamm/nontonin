# 🎬 Nontonin

**Nontonin** adalah aplikasi Android berbasis Flutter untuk membantu pengguna menemukan film yang ingin ditonton. Aplikasi ini menampilkan film yang sedang tayang, segera tayang, populer, dan berating tinggi, lalu memberikan rekomendasi sesuai genre dan rating pilihan pengguna. Setiap film dilengkapi trailer YouTube, informasi layanan streaming tempat film bisa ditonton di Indonesia, daftar pemeran, dan film serupa.

Seluruh data film diambil secara langsung (dinamis) dari **[TMDB API](https://developer.themoviedb.org/docs)**. Aplikasi hanya menampilkan film umum, sedangkan film animasi disaring keluar.

> Proyek ini dibuat untuk memenuhi Ujian Tengah Semester mata kuliah Pemrograman Mobile, Program Studi Teknik Informatika, UIN Maulana Malik Ibrahim Malang.

---

## ✨ Fitur Utama

| Fitur | Keterangan |
|---|---|
| **Beranda** | Banner *Trending Minggu Ini* yang bergeser otomatis, serta daftar *Sedang Tayang*, *Segera Tayang* (dengan tanggal rilis), *Populer*, dan *Rating Tertinggi*. Tersedia tarik-untuk-memuat-ulang (pull to refresh). |
| **Lihat Semua** | Daftar lengkap setiap kategori dengan tombol **Muat Lebih Banyak** (pagination). |
| **Rekomendasi** | Pilih satu atau beberapa genre, urutan (Terpopuler / Rating Tertinggi / Terbaru), dan rating minimum, lalu aplikasi mencarikan film yang cocok. |
| **Pencarian** | Cari film berdasarkan judul, dengan saran pencarian populer dan pencarian otomatis saat mengetik. |
| **Detail Film** | Poster, backdrop, rating, durasi, genre, sinopsis (bisa dibuka/tutup), info rilis, pemeran, dan film serupa. |
| **Tonton Trailer** | Membuka trailer resmi film tersebut langsung di **aplikasi YouTube**. |
| **Tersedia di** | Menampilkan layanan streaming, sewa, dan beli di Indonesia (Netflix, Disney+ Hotstar, Prime Video, dll.) beserta logonya. |
| **Favorit** | Simpan film ke daftar favorit (tersimpan di HP), hapus satu per satu atau semua, lengkap dengan fitur urungkan. |
| **Bagikan** | Bagikan film lewat WhatsApp, salin tautan, atau buka di situs TMDB. |
| **Kondisi data** | Setiap halaman menangani kondisi **loading** (skeleton), **sukses**, **error** (dengan tombol *Coba Lagi*), dan **data kosong**. |

---

## 🛠️ Teknologi dan Package

| Teknologi / Package | Fungsi |
|---|---|
| [Flutter](https://flutter.dev) & [Dart](https://dart.dev) | Framework dan bahasa pemrograman aplikasi |
| [TMDB API v3](https://developer.themoviedb.org/reference/intro/getting-started) | Sumber data film |
| [`http`](https://pub.dev/packages/http) | Mengirim permintaan HTTP ke TMDB API |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Huruf Poppins sesuai desain |
| [`intl`](https://pub.dev/packages/intl) | Format tanggal Bahasa Indonesia |
| [`path_provider`](https://pub.dev/packages/path_provider) | Lokasi penyimpanan file data favorit |
| `MethodChannel` (Kotlin) | Membuka aplikasi YouTube, browser, dan WhatsApp melalui Intent Android |

---

## 📁 Struktur Folder

```
lib/
├── config/
│   └── api_config.dart          # URL dasar, token TMDB, bahasa, wilayah
├── core/
│   ├── app_colors.dart          # Palet warna
│   ├── app_theme.dart           # Tema aplikasi
│   ├── formatters.dart          # Format tanggal, durasi, angka
│   └── genres.dart              # Daftar genre (Bahasa Indonesia)
├── models/
│   ├── movie.dart               # Model film + PagedMovies (fromJson/toJson)
│   └── movie_detail.dart        # Model detail, pemeran, video, penyedia
├── services/
│   ├── tmdb_service.dart        # Semua permintaan HTTP ke TMDB
│   ├── favorite_service.dart    # Penyimpanan favorit (file JSON lokal)
│   └── link_launcher.dart       # Membuka YouTube / browser
├── views/
│   ├── splash_page.dart
│   ├── main_shell.dart          # Bottom navigation 4 tab
│   ├── home_page.dart
│   ├── see_all_page.dart
│   ├── recommendation_page.dart
│   ├── recommendation_result_page.dart
│   ├── search_page.dart
│   ├── detail_page.dart
│   ├── favorite_page.dart
│   └── app_nav.dart             # Pengatur navigasi antarhalaman
├── widgets/                     # Komponen UI yang dipakai ulang
└── main.dart
test/
└── widget_test.dart             # Unit test parsing JSON & format data
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK versi stabil terbaru (Dart ≥ 3.13)
- Android Studio / VS Code dengan ekstensi Flutter
- Emulator Android atau HP Android dengan koneksi internet

### Langkah

1. **Clone repositori**
   ```bash
   git clone https://github.com/USERNAME/nontonin.git
   cd nontonin
   ```

2. **Unduh semua package**
   ```bash
   flutter pub get
   ```

3. **(Opsional) Ganti token TMDB**
   Buka `lib/config/api_config.dart`, lalu ganti `readAccessToken` dengan *API Read Access Token* milikmu dari [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api).

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

5. **(Opsional) Jalankan pengujian unit**
   ```bash
   flutter test
   ```

---

## 📸 Tampilan Aplikasi

<table>
  <tr>
    <td align="center"><img src="screenshots/splash.png" width="200"/><br/><b>Splash Screen</b></td>
    <td align="center"><img src="screenshots/beranda.png" width="200"/><br/><b>Beranda</b></td>
    <td align="center"><img src="screenshots/rekomendasi.png" width="200"/><br/><b>Rekomendasi</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/hasil_rekomendasi.png" width="200"/><br/><b>Hasil Rekomendasi</b></td>
    <td align="center"><img src="screenshots/cari.png" width="200"/><br/><b>Pencarian</b></td>
    <td align="center"><img src="screenshots/detail.png" width="200"/><br/><b>Detail Film</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/tersedia_di.png" width="200"/><br/><b>Tersedia di & Sinopsis</b></td>
    <td align="center"><img src="screenshots/favorit.png" width="200"/><br/><b>Favorit</b></td>
    <td align="center"><img src="screenshots/error.png" width="200"/><br/><b>Kondisi Error</b></td>
  </tr>
</table>

---

## 🙏 Atribusi

This product uses the TMDB API but is not endorsed or certified by TMDB.
Data layanan streaming disediakan oleh **JustWatch** melalui TMDB.
