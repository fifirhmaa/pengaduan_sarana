import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../aspirasi/presentation/pages/siswa/input_aspirasi_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9B5CFF), Color(0xFF6C7BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sistem Keluhan Fasilitas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sekolah Menengah Atas',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),

            // 🔹 SISWA
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InputAspirasiPage(),
                  ),
                );
              },
              child: const Text('Laporkan Keluhan'),
            ),

            const SizedBox(height: 12),

            // 🔹 ADMIN
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin-login');
              },
              child: const Text('Login Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
