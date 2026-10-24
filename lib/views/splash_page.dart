import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'main_shell.dart';

/// Halaman pembuka yang tampil sebentar saat aplikasi dibuka.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Logo + tagline, sedikit di atas tengah layar.
            Align(
              alignment: Alignment(0, -0.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(),
                  SizedBox(height: 18),
                  Text(
                    'Temukan film favoritmu berikutnya',
                    style: TextStyle(
                        fontSize: 13.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Indikator memuat yang berputar.
            Align(
              alignment: Alignment(0, 0.68),
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                  backgroundColor: Color(0x33E50914),
                ),
              ),
            ),
            // Atribusi TMDB.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 28),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: 'TMDB   ',
                        style: TextStyle(
                          color: Color(0xFF01B4E4),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: 'Data film disediakan oleh TMDB'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo Nontonin: kotak merah berikon play dengan garis putus-putus
/// (seperti tiket/film strip) + tulisan "Nontonin".
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: size * 0.6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _DashedLinePainter(),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: size * 0.08),
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: size * 0.6),
              ),
            ),
          ),
        ),
        SizedBox(width: size * 0.26),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Nonton'),
              TextSpan(
                text: 'in',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Garis putus-putus vertikal di sisi kanan logo.
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1;
    final x = size.width * 0.8;
    const dash = 3.0;
    const gap = 2.5;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
