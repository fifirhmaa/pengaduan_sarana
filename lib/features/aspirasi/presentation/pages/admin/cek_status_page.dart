import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../data/siswa/aspirasi_siswa_services.dart';

class CekStatusPage extends StatefulWidget {
  const CekStatusPage({super.key});

  @override
  State<CekStatusPage> createState() => _CekStatusPageState();
}

class _CekStatusPageState extends State<CekStatusPage> {
  final nisController = TextEditingController();
  final service = AspirasiSiswaService();

  List<RecordModel> list = [];
  bool loading = false;

  Future<void> cari() async {
    if (nisController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final data =
          await service.getAspirasiByNis(nisController.text);

      setState(() {
        list = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

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
              decoration: const InputDecoration(
                labelText: 'Masukkan NIS',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: cari,
              child: const Text('Cek'),
            ),
            const SizedBox(height: 16),

            if (loading) const CircularProgressIndicator(),

            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final a = list[i];
                  final kategori =
                      a.expand['kategori']?.first.data['kategori'];

                  return Card(
                    child: ListTile(
                      title: Text(a.data['keterangan']),
                      subtitle: Text(
                        'Kategori: $kategori\n'
                        'Status: ${a.data['status']}\n'
                        'Feedback: ${a.data['feedback'] ?? '-'}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
