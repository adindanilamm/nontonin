import 'package:flutter/material.dart';

import '../core/app_colors.dart';

enum SnackType { success, error, neutral }

/// Penanda notifikasi terakhir, supaya timer notifikasi lama
/// tidak ikut menutup notifikasi yang baru muncul.
int _snackSeq = 0;

/// Menampilkan notifikasi singkat di bagian bawah layar.
///
/// Notifikasi selalu tertutup otomatis setelah [duration], termasuk
/// notifikasi yang memiliki tombol aksi (LIHAT / URUNGKAN). Di Flutter
/// versi baru, SnackBar yang punya tombol aksi tidak hilang sendiri,
/// jadi ditutup manual dengan timer.
void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackType type = SnackType.success,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final Color bg;
  final IconData icon;
  switch (type) {
    case SnackType.success:
      bg = AppColors.success;
      icon = Icons.check_circle_rounded;
    case SnackType.error:
      bg = AppColors.primaryPressed;
      icon = Icons.error_rounded;
    case SnackType.neutral:
      bg = AppColors.surfaceElevated;
      icon = Icons.info_rounded;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final id = ++_snackSeq;
  final controller = messenger.showSnackBar(
    SnackBar(
      backgroundColor: bg,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dismissDirection: DismissDirection.horizontal,
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            ),
    ),
  );

  // Tutup otomatis setelah durasi selesai.
  Future.delayed(duration, () {
    if (id != _snackSeq) return; // sudah diganti notifikasi lain
    try {
      controller.close();
    } catch (_) {
      // Notifikasi sudah tertutup lebih dulu (misalnya digeser pengguna).
    }
  });
}
