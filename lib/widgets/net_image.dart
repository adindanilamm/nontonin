import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Gambar dari internet dengan tampilan sementara saat memuat
/// dan ikon pengganti jika gambar gagal dimuat atau tidak tersedia.
class NetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;

  const NetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholderIcon = Icons.movie_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.surfaceElevated,
      alignment: Alignment.center,
      child: Icon(placeholderIcon, color: AppColors.muted, size: 32),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      width: width,
                      height: height,
                      color: AppColors.surfaceElevated,
                    ),
              errorBuilder: (context, error, stack) => placeholder,
            ),
    );
  }
}
