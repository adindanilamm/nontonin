import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Judul bagian dengan tombol "Lihat Semua" di sebelah kanan.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lihat Semua', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
