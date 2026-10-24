import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'views/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal Bahasa Indonesia (contoh: 12 Mar 2025).
  await initializeDateFormatting('id_ID');

  // Ikon status bar berwarna terang agar terlihat di tema gelap.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const NontoninApp());
}

class NontoninApp extends StatelessWidget {
  const NontoninApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nontonin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashPage(),
    );
  }
}
