import 'package:flutter/material.dart';
import 'package:ukk_pengaduan/features/auth/presentation/pages/auth_gate.dart';

import 'core/pocketbase_client.dart';
import 'features/aspirasi/presentation/pages/admin/admin_aspirasi_page.dart';
import 'features/aspirasi/presentation/pages/admin/cek_statur_page.dart';
import 'features/auth/presentation/pages/login_admin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔌 TEST KONEKSI POCKETBASE
  try {
    final list = await pb.collection('kategori').getList();
    debugPrint('KONEK: ${list.items.length}');
  } catch (e) {
    debugPrint('GAGAL KONEK: $e');
  }

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
        '/cek-status': (context) => const CekStatusPage(),
        '/admin-login': (c) => const AdminLoginPage(),
      },
    );
  }
}
