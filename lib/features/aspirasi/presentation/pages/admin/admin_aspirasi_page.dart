import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/admin/aspirasi_admin_services.dart';

class AdminAspirasiPage extends StatefulWidget {
  const AdminAspirasiPage({super.key});

  @override
  State<AdminAspirasiPage> createState() => _AdminAspirasiPageState();
}

class _AdminAspirasiPageState extends State<AdminAspirasiPage> {
  final service = AspirasiAdminService();
  List<RecordModel> list = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Aspirasi')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (c, i) {
                final a = list[i];
                final kategori = a.expand['kategori']?.first.data['kategori'];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(a.data['keterangan']),
                    subtitle: Text(
                      'NIS: ${a.data['nis']} • '
                      'Kategori: $kategori • '
                      'Status: ${a.data['status']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => openEdit(a),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getAllAspirasi();
    setState(() {
      list = data;
      loading = false;
    });
  }

  void openEdit(RecordModel a) {
    final feedbackCtrl = TextEditingController(text: a.data['feedback'] ?? '');
    String status = a.data['status'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Aspirasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                DropdownMenuItem(value: 'Proses', child: Text('Proses')),
                DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
              ],
              onChanged: (v) => status = v!,
            ),
            TextField(
              controller: feedbackCtrl,
              decoration: const InputDecoration(labelText: 'Feedback'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.updateStatus(
                aspirasiId: a.id,
                status: status,
                feedback: feedbackCtrl.text,
              );
              Navigator.pop(context);
              load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
