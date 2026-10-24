import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'app_buttons.dart';

/// Tampilan kondisi khusus: error, data kosong, atau hasil tidak ditemukan.
class StateView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;
  final bool primaryButton;

  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.muted,
    this.buttonLabel,
    this.buttonIcon,
    this.onPressed,
    this.primaryButton = true,
  });

  /// Kondisi error standar dengan tombol "Coba Lagi".
  factory StateView.error({
    required String message,
    required VoidCallback onRetry,
  }) =>
      StateView(
        icon: Icons.wifi_off_rounded,
        iconColor: AppColors.error,
        title: 'Gagal Memuat Film',
        message: message,
        buttonLabel: 'Coba Lagi',
        buttonIcon: Icons.refresh_rounded,
        onPressed: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: primaryButton
                    ? PrimaryButton(
                        label: buttonLabel!,
                        icon: buttonIcon,
                        onPressed: onPressed,
                      )
                    : SecondaryButton(
                        label: buttonLabel!,
                        icon: buttonIcon,
                        onPressed: onPressed,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
