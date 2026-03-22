import 'package:flutter/material.dart';
import 'package:ukk_pengaduan/features/auth/presentation/pages/auth_gate.dart';

import 'features/aspirasi/presentation/pages/admin/admin_aspirasi_page.dart';
import 'features/aspirasi/presentation/pages/siswa/riwayat_aspirasi.dart';
import 'features/auth/presentation/pages/login_admin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/admin-aspirasi': (context) => const AdminAspirasiPage(),
        '/riwayat-aspirasi': (context) => const RiwayatAspirasi(),
        '/admin-login': (c) => const AdminLoginPage(),
      },
    );
  }
}
