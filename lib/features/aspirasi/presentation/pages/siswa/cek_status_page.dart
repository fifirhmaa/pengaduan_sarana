import 'package:flutter/material.dart';

import 'riwayat_aspirasi_siswa_page.dart';

class CekStatusPage extends StatefulWidget {
  const CekStatusPage({super.key});

  @override
  State<CekStatusPage> createState() => _CekStatusPageState();
}

class _CekStatusPageState extends State<CekStatusPage> {
  final nisController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Status Aspirasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Masukkan NIS'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _cekStatus, child: const Text('Cek')),
          ],
        ),
      ),
    );
  }

  void _cekStatus() {
    final nis = nisController.text.trim();
    if (nis.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('NIS wajib diisi')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RiwayatAspirasiSiswa(nis: nis)),
    );
  }
}
